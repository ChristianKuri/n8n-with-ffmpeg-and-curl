# Custom n8n Docker Image

This repository maintains a custom n8n Docker image with additional packages installed:

- **ffmpeg** - Video/audio processing
- **curl** - HTTP client
- **yt-dlp** - Video downloader

## Features

- **Automatically stays up-to-date** with the latest n8n releases
- **Multi-architecture support** - works on both AMD64 (x86_64) and ARM64 (Apple Silicon, Raspberry Pi, etc.)
- **Traefik-ready** - Includes labels for automatic HTTPS with Traefik
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

This repo includes a production-ready `docker-compose.yml` with PostgreSQL, Redis, and Traefik support.

### 1. Clone the repository

```bash
git clone https://github.com/christiankuri/n8n-with-ffmpeg-and-curl.git
cd n8n-with-ffmpeg-and-curl
```

### 2. Configure environment variables

```bash
cp .env.example .env
nano .env  # Edit with your values
```

### 3. Create the Traefik network (if using Traefik)

```bash
docker network create traefik
```

### 4. Start the services

```bash
docker compose up -d
```

### 5. Access n8n

- **With Traefik**: `https://n8n.yourdomain.com`
- **Without Traefik**: `http://localhost:5678`

## Deployment Options

### Option A: With Traefik (Recommended for Production)

The docker-compose includes Traefik labels for automatic HTTPS. Make sure you have:

1. Traefik running with Let's Encrypt configured
2. DNS pointing to your server
3. The `traefik` network created

```bash
# Create the network if it doesn't exist
docker network create traefik

# Start n8n
docker compose up -d
```

### Option B: Without Traefik

If you're not using Traefik, set these in your `.env`:

```env
TRAEFIK_ENABLE=false
```

Then access n8n directly at `http://localhost:5678` or configure your own reverse proxy.

## Environment Variables

### n8n Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `N8N_HOST` | - | Your n8n domain (e.g., `n8n.yourdomain.com`) |
| `N8N_ENCRYPTION_KEY` | - | Encryption key (generate with `openssl rand -hex 32`) |
| `N8N_PORT` | `5678` | Port to expose n8n |
| `N8N_PAYLOAD_SIZE_MAX` | `512` | Max payload size in MB |
| `NODE_MAX_MEMORY` | `4096` | Node.js max memory in MB |
| `N8N_DATA_PATH` | `/mnt` | Host path to mount as /data |

### PostgreSQL Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_VERSION` | `16` | PostgreSQL version |
| `POSTGRES_DB` | - | Database name |
| `POSTGRES_USER` | - | Root user |
| `POSTGRES_PASSWORD` | - | Root password |
| `POSTGRES_NON_ROOT_USER` | - | n8n database user |
| `POSTGRES_NON_ROOT_PASSWORD` | - | n8n database password |

### Traefik Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `TRAEFIK_ENABLE` | `true` | Enable Traefik labels |
| `TRAEFIK_NETWORK` | `traefik` | Traefik's Docker network |
| `TRAEFIK_CERTRESOLVER` | `letsencrypt` | Certificate resolver name |
| `N8N_TRAEFIK_ROUTER` | `n8n` | Router name (change for multiple instances) |

## Supported Architectures

| Architecture | Tag |
|--------------|-----|
| x86_64 / AMD64 | `linux/amd64` |
| ARM64 / Apple Silicon | `linux/arm64` |

The image is built as a multi-platform manifest, so Docker will automatically pull the correct architecture for your system.

## Sample Workflows

The `sample-workflows/` directory contains ready-to-import n8n workflows that demonstrate the installed tools:

### 1. Test FFmpeg Tools (`test-ffmpeg-tools.json`)
Simple workflow to verify that ffmpeg, curl, and yt-dlp are installed correctly.

### 2. Download Video & Extract Audio (`download-and-convert-video.json`)
Downloads a video using yt-dlp and extracts audio as MP3 using FFmpeg.

### 3. Fetch & Process Media (`fetch-and-process-media.json`)
Demonstrates:
- Downloading media with curl
- Creating thumbnails from video
- Extracting audio tracks
- Re-encoding video files

**To import:** In n8n, go to **Workflows** → **Import from File** → Select the JSON file.

## Building Locally

```bash
# Build for your current architecture
docker build -t n8n-custom .

# Build for multiple architectures
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

## License

MIT
