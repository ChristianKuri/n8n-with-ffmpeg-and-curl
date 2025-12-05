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
docker pull ghcr.io/christiankuri/n8n-with-ffmpeg-and-curl:latest

# Using a specific n8n version
docker pull ghcr.io/christiankuri/n8n-with-ffmpeg-and-curl:1.70.0
```

## Quick Start with Docker Compose

This repo includes a production-ready `docker-compose.yml` with PostgreSQL and Redis.

### 1. Clone the repository

```bash
git clone https://github.com/christiankuri/n8n-with-ffmpeg-and-curl.git
cd n8n-with-ffmpeg-and-curl
```

### 2. Configure environment variables

```bash
cp .env.example .env
# Edit .env with your values
```

### 3. Start the services

```bash
docker compose up -d
```

### 4. Access n8n

Open `http://localhost:5678` in your browser (or your configured `HOST`).

## Environment Variables

| Variable | Description |
|----------|-------------|
| `HOST` | Your n8n domain (e.g., `n8n.yourdomain.com`) |
| `POSTGRES_DB` | PostgreSQL database name |
| `POSTGRES_USER` | PostgreSQL root user |
| `POSTGRES_PASSWORD` | PostgreSQL root password |
| `POSTGRES_NON_ROOT_USER` | PostgreSQL user for n8n |
| `POSTGRES_NON_ROOT_PASSWORD` | PostgreSQL password for n8n |
| `ENCRYPTION_KEY` | n8n encryption key (generate with `openssl rand -hex 32`) |

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

No additional secrets are required for the container registry! The workflow uses:

- `GITHUB_TOKEN` - Automatically provided by GitHub Actions for pushing to ghcr.io
- `PAT_GITHUB` - Personal Access Token with repo scope (for updating the version file)
