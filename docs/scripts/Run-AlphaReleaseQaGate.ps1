[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Tag,

    [string]$Repo = "tegllundj-dotcom/NulleCore-eAI",

    [string]$ChecksumsPath = "",

    [string]$GhPath = "",

    [switch]$RequirePrerelease,

    [string]$IssueNumber,

    [string]$OutCommentFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ChecksumsPath)) {
    $ChecksumsPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\CHECKSUMS.txt"
}

function Resolve-GhCommand([string]$ExplicitPath) {
    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        if (Test-Path -LiteralPath $ExplicitPath) {
            return $ExplicitPath
        }
        throw "Provided GhPath does not exist: $ExplicitPath"
    }

    $inPath = Get-Command gh -ErrorAction SilentlyContinue
    if ($inPath) {
        return $inPath.Source
    }

    $fallback = "C:\Program Files\GitHub CLI\gh.exe"
    if (Test-Path -LiteralPath $fallback) {
        return $fallback
    }

    throw "GitHub CLI not found. Install gh or provide -GhPath."
}

function Parse-ChecksumsFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Checksums file not found: $Path"
    }

    $expected = @{}
    $lines = Get-Content -LiteralPath $Path
    foreach ($lineRaw in $lines) {
        $line = $lineRaw.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
            continue
        }

        if ($line -match '^([A-Fa-f0-9]{64})\s+release-assets\/(.+)$') {
            $hash = $matches[1].ToUpperInvariant()
            $fileName = $matches[2]
            $expected[$fileName] = $hash
            continue
        }

        if ($line -match '^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}$') {
            continue
        }

        Write-Warning "Ignoring non-standard checksum line: $line"
    }

    if ($expected.Count -eq 0) {
        throw "No valid release asset entries parsed from checksums file: $Path"
    }

    return $expected
}

function Get-Release([string]$Repository, [string]$ReleaseTag) {
    $json = & $script:GhCommand release view $ReleaseTag --repo $Repository --json tagName,isDraft,isPrerelease,url,assets
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to read release metadata for $ReleaseTag in $Repository"
    }
    return ($json | ConvertFrom-Json)
}

function Convert-ReleaseAssets([object[]]$Assets) {
    $map = @{}
    foreach ($asset in $Assets) {
        $map[$asset.name] = $asset
    }
    return $map
}

function New-QaReport(
    [object]$Release,
    [hashtable]$ExpectedChecksums,
    [hashtable]$ReleaseAssets
) {
    $results = @()
    foreach ($name in $ExpectedChecksums.Keys) {
        if (-not $ReleaseAssets.ContainsKey($name)) {
            $results += [pscustomobject]@{
                AssetName = $name
                ExpectedHash = $ExpectedChecksums[$name]
                ActualHash = $null
                Found = $false
                Match = $false
            }
            continue
        }

        $digest = [string]$ReleaseAssets[$name].digest
        $actualHash = $null
        if ($digest -match '^sha256:(.+)$') {
            $actualHash = $matches[1].ToUpperInvariant()
        }

        $results += [pscustomobject]@{
            AssetName = $name
            ExpectedHash = $ExpectedChecksums[$name]
            ActualHash = $actualHash
            Found = $true
            Match = ($actualHash -eq $ExpectedChecksums[$name])
        }
    }

    $allFound = @($results | Where-Object { -not $_.Found }).Count -eq 0
    $allMatched = @($results | Where-Object { -not $_.Match }).Count -eq 0
    $isPrereleaseOk = if ($RequirePrerelease) { [bool]$Release.isPrerelease } else { $true }

    [pscustomobject]@{
        ReleaseTag = $Release.tagName
        ReleaseUrl = $Release.url
        IsDraft = [bool]$Release.isDraft
        IsPrerelease = [bool]$Release.isPrerelease
        RequirePrerelease = [bool]$RequirePrerelease
        AllExpectedAssetsFound = $allFound
        AllExpectedHashesMatch = $allMatched
        PrereleasePolicyPass = $isPrereleaseOk
        AssetResults = $results
    }
}

function New-QaMarkdown([object]$Report, [string]$RepoName, [string]$ChecksumsFilePath) {
    $date = Get-Date -Format "yyyy-MM-dd"
    $pass = ($Report.AllExpectedAssetsFound -and $Report.AllExpectedHashesMatch -and -not $Report.IsDraft -and $Report.PrereleasePolicyPass)
    $status = if ($pass) { "PASS" } else { "FAIL" }

    function Get-Mark([bool]$Condition) {
        if ($Condition) { return "[x]" }
        return "[ ]"
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("QA run for ``$($Report.ReleaseTag)`` ($date)")
    $lines.Add("")
    $lines.Add("- Repository: ``$RepoName``")
    $lines.Add("- Release: $($Report.ReleaseUrl)")
    $lines.Add("- Status: **$status**")
    $lines.Add("- Draft: ``$($Report.IsDraft.ToString().ToLowerInvariant())``")
    $lines.Add("- Prerelease: ``$($Report.IsPrerelease.ToString().ToLowerInvariant())``")
    $lines.Add("- Require prerelease policy: ``$($Report.RequirePrerelease.ToString().ToLowerInvariant())``")
    $lines.Add("- Checksums source: ``$ChecksumsFilePath``")
    $lines.Add("")
    $lines.Add("Asset verification:")

    foreach ($r in $Report.AssetResults) {
        $marker = if ($r.Match -and $r.Found) { "[x]" } else { "[ ]" }
        $actual = if ($r.ActualHash) { $r.ActualHash } else { "missing" }
        $lines.Add("- $marker ``$($r.AssetName)`` expected ``$($r.ExpectedHash)`` got ``$actual``")
    }

    $lines.Add("")
    $lines.Add("Summary checks:")
    $lines.Add("- $(Get-Mark $Report.AllExpectedAssetsFound) all expected assets found")
    $lines.Add("- $(Get-Mark $Report.AllExpectedHashesMatch) all expected SHA256 hashes match")
    $lines.Add("- $(Get-Mark (-not $Report.IsDraft)) release is not draft")
    $lines.Add("- $(Get-Mark $Report.PrereleasePolicyPass) prerelease policy satisfied")

    return ($lines -join [Environment]::NewLine)
}

$script:GhCommand = Resolve-GhCommand -ExplicitPath $GhPath

& $script:GhCommand auth status 1>$null 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run: gh auth login"
}

$expectedChecksums = Parse-ChecksumsFile -Path $ChecksumsPath
$release = Get-Release -Repository $Repo -ReleaseTag $Tag
$releaseAssets = Convert-ReleaseAssets -Assets $release.assets
$report = New-QaReport -Release $release -ExpectedChecksums $expectedChecksums -ReleaseAssets $releaseAssets
$commentBody = New-QaMarkdown -Report $report -RepoName $Repo -ChecksumsFilePath $ChecksumsPath

Write-Host ""
Write-Host "=== Alpha Release QA Gate Report ==="
Write-Host $commentBody
Write-Host ""

if ($OutCommentFile) {
    $outDir = Split-Path -Path $OutCommentFile -Parent
    if (-not [string]::IsNullOrWhiteSpace($outDir) -and -not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir | Out-Null
    }
    Set-Content -LiteralPath $OutCommentFile -Value $commentBody -Encoding UTF8
    Write-Host "Comment markdown written to: $OutCommentFile"
}

if ($IssueNumber) {
    $tmp = Join-Path $env:TEMP ("nullecore-qagate-" + [Guid]::NewGuid().ToString("N") + ".md")
    Set-Content -LiteralPath $tmp -Value $commentBody -Encoding UTF8
    try {
        & $script:GhCommand issue comment $IssueNumber --repo $Repo --body-file $tmp
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to post QA comment to issue #$IssueNumber"
        }
        Write-Host "Posted QA report to issue #$IssueNumber in $Repo"
    }
    finally {
        if (Test-Path -LiteralPath $tmp) {
            Remove-Item -LiteralPath $tmp -Force
        }
    }
}

$hardPass = ($report.AllExpectedAssetsFound -and $report.AllExpectedHashesMatch -and -not $report.IsDraft -and $report.PrereleasePolicyPass)
if (-not $hardPass) {
    exit 2
}

exit 0
