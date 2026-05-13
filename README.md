# NulleCore eAI

NulleCore eAI is a local-first Windows AI workspace for private creative and productivity workflows.

## Overview

NulleCore eAI is a desktop control surface for running AI workflows on your own machine with user-controlled setup, readiness checks, and curated workflow governance.

Status: **Alpha / Early Preview**

## Positioning

- Local-first
- Privacy-first
- User-controlled runtime setup
- Experimental early-access software

## Key Features

- Windows desktop workspace experience
- LM Studio readiness support
- ComfyUI readiness support
- Curated workflow layer
- Local AI control surface
- Installer-based distribution

## What It Is Not

- Not a cloud AI service
- Not a hosted SaaS
- Not an open-source release yet
- Not a replacement for LM Studio or ComfyUI

## Installation

1. Go to `release-assets/`.
2. Download either:
   - `NulleCore-eAI-Setup-v0.1.0-alpha.msi`
   - `NulleCore-eAI-v0.1.0-alpha-win-x64.zip`
3. Verify file integrity with `CHECKSUMS.txt`.
4. Run the MSI, or extract and run the executable from the ZIP package.

## System Requirements

- Windows 11 or Windows 10 x64
- Local disk space for desktop app and optional local model workflows
- Optional external tools:
  - LM Studio (local LLM runtime)
  - ComfyUI (local image workflow runtime)

## Known Limitations

- Alpha quality and active iteration
- Unknown publisher warning may appear until code signing is finalized
- Some product areas still rely on sample/static content in this stage
- External runtimes are user-managed dependencies

## Roadmap Summary

- Stabilize release pipeline and signing gate
- Improve first-run onboarding for local runtimes
- Expand curated workflow examples and validation
- Continue polish for private creative AI workspace UX

See `ROADMAP.md` for details.

## Safety and Security Note

- NulleCore eAI is designed for local-first use.
- Do not place credentials, keys, or sensitive files into workflow inputs without proper local controls.
- Verify release assets with checksums before installation.

See `SECURITY.md` for reporting and guidance.

## Contact

- Contact placeholder: `security@nullecore.local`
- Product updates placeholder: `hello@nullecore.local`
