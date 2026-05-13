# Troubleshooting

## App Starts but Runtime Is Not Ready

- Confirm LM Studio local API is running if chat features are needed.
- Confirm ComfyUI API is running if image features are needed.

## Unknown Publisher Warning

- This may appear until code signing is finalized.
- Verify asset integrity via `CHECKSUMS.txt`.

## Installer Issues

- Re-run installer with local admin context if needed.
- Remove old preview installs before retrying.

## Endpoint Sanity Checks

- LM Studio: `http://localhost:1234/v1/models`
- ComfyUI: `http://127.0.0.1:8188/system_stats`
