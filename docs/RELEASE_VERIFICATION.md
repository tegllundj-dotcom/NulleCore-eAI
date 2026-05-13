# Release Verification Log

This document tracks public release verification for showcase quality control.

## Process (for each new alpha tag)

1. Run the QA gate checklist in issue [#5 Release QA Gate (Alpha)](https://github.com/tegllundj-dotcom/NulleCore-eAI/issues/5).
   Optionally run `docs/scripts/Run-AlphaReleaseQaGate.ps1` to generate a deterministic QA summary.
2. Validate release assets, checksums, and prerelease state.
3. Add a new section in this file for the new release tag.
4. Link the QA gate run comment and any relevant issue updates.

Use this structure:

```text
## vX.Y.Z-alpha Verification
Verification date: YYYY-MM-DD
Release: <tag link>
Type: prerelease (public alpha)
QA gate run: <issue comment link>
```

## v0.1.0-alpha Verification

Verification date: 2026-05-13  
Release: [v0.1.0-alpha](https://github.com/tegllundj-dotcom/NulleCore-eAI/releases/tag/v0.1.0-alpha)  
Type: prerelease (public alpha)  
QA gate run: [Issue #5 comment](https://github.com/tegllundj-dotcom/NulleCore-eAI/issues/5#issuecomment-4442417938)

### Assets checked

- `CHECKSUMS.txt`
- `NulleCore-eAI-Setup-v0.1.0-alpha.msi`
- `NulleCore-eAI-v0.1.0-alpha-win-x64.zip`

### Integrity result

The release API digests match the values declared in `CHECKSUMS.txt`:

- MSI SHA256: `9D7F6C1F9F609FAC706449BF0E1D85E983BB53F8C79B6321516AD0F8AE173826`
- ZIP SHA256: `4F3269C19791BEFE6A4A50C1D7FFB798C860595BEAF1491054C2457329522DD5`

### Release state

- Draft: `false`
- Prerelease: `true`
- Visibility: public repository

### Notes

- This is a technical release verification log, not a production security certification.
- Binaries are currently unsigned; Windows warnings may appear until signing is introduced.
