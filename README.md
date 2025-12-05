# Custom n8n Docker Image

This repository maintains a custom n8n Docker image with additional packages installed:

- ffmpeg
- curl
- yt-dlp

## Features

- **Automatically stays up-to-date** with the latest n8n releases
- **Multi-architecture support** - works on both AMD64 (x86_64) and ARM64 (Apple Silicon, Raspberry Pi, etc.)
- Builds and pushes to **GitHub Container Registry** every 6 hours if a new n8n version is available
- Maintains both versioned tags and a `latest` tag
- Build attestation for supply chain security

## Usage

Pull the image from GitHub Container Registry:

```bash
# Using the latest tag
docker pull ghcr.io/OWNER/n8n-with-ffmpeg-and-curl:latest

# Using a specific n8n version
docker pull ghcr.io/OWNER/n8n-with-ffmpeg-and-curl:1.70.0
```

> **Note:** Replace `OWNER` with your GitHub username or organization name.

### Docker Compose Example

```yaml
services:
  n8n:
    image: ghcr.io/OWNER/n8n-with-ffmpeg-and-curl:latest
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=changeme
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

## Supported Architectures

| Architecture | Tag |
|--------------|-----|
| x86_64 / AMD64 | `linux/amd64` |
| ARM64 / Apple Silicon | `linux/arm64` |

The image is built as a multi-platform manifest, so Docker will automatically pull the correct architecture for your system.

## Building Locally

```bash
# Build for your current architecture
docker build -t n8n-custom .

# Build for a specific architecture
docker buildx build --platform linux/amd64,linux/arm64 -t n8n-custom .
```

## GitHub Actions Workflow

The workflow automatically:

1. Checks for new n8n releases every 6 hours
2. Builds multi-architecture images (AMD64 + ARM64) using QEMU emulation
3. Pushes to GitHub Container Registry (ghcr.io)
4. Generates build attestation for supply chain security
5. Updates the version tracker file

### Required Repository Settings

No additional secrets are required! The workflow uses:

- `GITHUB_TOKEN` - Automatically provided by GitHub Actions for pushing to ghcr.io
- `PAT_GITHUB` - Personal Access Token with repo scope (for updating the version file)
