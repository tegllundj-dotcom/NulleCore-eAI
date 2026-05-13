# GitHub Public Showcase Setup

This file documents recommended manual GitHub settings for the public alpha showcase.

## Suggested Repository Description

`Local-first AI creative workstation for Windows and offline AI orchestration.`

## Suggested Topics

- `ai`
- `local-ai`
- `windows`
- `wpf`
- `lmstudio`
- `comfyui`
- `offline-ai`
- `creative-tools`
- `image-workflows`
- `orchestration`

## Visibility and Pinning

- Keep repository visibility aligned with launch plan.
- Pin this repository on the owner profile during alpha outreach.
- Keep the key testing issues pinned:
  - Community Testing Hub
  - Known Limitations
  - What To Test First

## Release Verification Checklist

Before each public release update:

1. Verify release assets are the intended final binaries.
2. Recompute and upload `CHECKSUMS.txt`.
3. Confirm release notes match shipped artifacts.
4. Run the QA gate checklist in issue `#5 Release QA Gate (Alpha)` and post a run comment.
5. Update `docs/RELEASE_VERIFICATION.md` with the new release tag and QA gate comment link.
6. Confirm issue template still matches current test goals.
7. Keep release marked as prerelease while in alpha.

## Account and Billing Hygiene

- Review GitHub account/org warnings regularly (billing, actions quota, security prompts).
- Resolve visible account warnings before broader public promotion.
- Keep branch protection and access control settings intentional.
