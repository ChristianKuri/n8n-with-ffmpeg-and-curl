# Custom n8n Docker Image

Custom n8n Docker image with **ffmpeg**, **curl**, and **yt-dlp** pre-installed for media processing workflows.

## Features

- **ffmpeg** - Video/audio processing
- **curl** - HTTP client  
- **yt-dlp** - Video downloader
- **Multi-architecture** - AMD64 & ARM64 (Apple Silicon, Raspberry Pi)
- **Auto-updates** - Rebuilds when new n8n versions are released
- **Flexible deployment** - Standalone, Traefik, Dokploy, or any PaaS

## Quick Start

### Standalone (No Reverse Proxy)

```bash
git clone https://github.com/christiankuri/n8n-with-ffmpeg-and-curl.git
cd n8n-with-ffmpeg-and-curl

cp .env.example .env
nano .env  # Set your passwords and encryption key

docker compose up -d
```

Access n8n at `http://localhost:5678`

### With Traefik

```bash
# 1. Create traefik network (if not exists)
docker network create traefik

# 2. Configure .env
cp .env.example .env
nano .env  # Set N8N_HOST, passwords, etc.

# 3. Start with Traefik override
docker compose -f docker-compose.yml -f docker-compose.traefik.yml up -d
```

Access n8n at `https://your-domain.com`

### With Dokploy

**Step 1:** In Dokploy's compose settings, set the compose command to:

```
-f docker-compose.yml -f docker-compose.dokploy.yml
```

**Step 2:** Set these environment variables in Dokploy UI:

| Variable | Value |
|----------|-------|
| `N8N_HOST` | `n8n.yourdomain.com` |
| `N8N_ENCRYPTION_KEY` | Your key (run `openssl rand -hex 32`) |
| `POSTGRES_USER` | `postgres` |
| `POSTGRES_PASSWORD` | Secure password |
| `POSTGRES_DB` | `n8n` |
| `POSTGRES_NON_ROOT_USER` | `n8n` |
| `POSTGRES_NON_ROOT_PASSWORD` | Secure password |

**Step 3:** Choose your domain configuration method:

| Option | How to |
|--------|--------|
| **A: Dokploy UI** (recommended) | Leave `TRAEFIK_ENABLE` unset or `false`, configure domain in Dokploy's Domains UI |
| **B: Labels** | Set `TRAEFIK_ENABLE=true` and `N8N_HOST=your-domain.com` |

## Deployment Options Summary

| Deployment | Command |
|------------|---------|
| **Standalone** | `docker compose up -d` |
| **Traefik** | `docker compose -f docker-compose.yml -f docker-compose.traefik.yml up -d` |
| **Dokploy** | `-f docker-compose.yml -f docker-compose.dokploy.yml` in Dokploy UI |

## Pull Image Directly

```bash
docker pull ghcr.io/christiankuri/n8n-with-ffmpeg-and-curl:latest
```

## Environment Variables

### Required

| Variable | Description |
|----------|-------------|
| `N8N_HOST` | Your domain (e.g., `n8n.example.com`) |
| `N8N_ENCRYPTION_KEY` | Encryption key - `openssl rand -hex 32` |
| `POSTGRES_USER` | PostgreSQL root user |
| `POSTGRES_PASSWORD` | PostgreSQL root password |
| `POSTGRES_DB` | Database name |
| `POSTGRES_NON_ROOT_USER` | n8n database user |
| `POSTGRES_NON_ROOT_PASSWORD` | n8n database password |

### Optional

| Variable | Default | Description |
|----------|---------|-------------|
| `N8N_PORT` | `5678` | Port to expose |
| `N8N_DATA_PATH` | `/mnt` | Host path for /data mount |
| `NODE_MAX_MEMORY` | `4096` | Node.js max memory (MB) |
| `POSTGRES_VERSION` | `16` | PostgreSQL version |
| `REDIS_VERSION` | `6-alpine` | Redis version |

### Traefik Variables (when using docker-compose.traefik.yml)

| Variable | Default | Description |
|----------|---------|-------------|
| `TRAEFIK_NETWORK` | `traefik` | Traefik's Docker network |
| `TRAEFIK_CERTRESOLVER` | `letsencrypt` | Certificate resolver |
| `N8N_TRAEFIK_ROUTER` | `n8n` | Router name |

## Sample Workflows

Import these from `sample-workflows/` to test the installed tools:

| File | Description |
|------|-------------|
| `test-ffmpeg-tools.json` | Verify ffmpeg, curl, yt-dlp installation |
| `download-and-convert-video.json` | Download video, extract audio |
| `fetch-and-process-media.json` | Thumbnails, audio extraction, re-encoding |

## Supported Architectures

| Architecture | Platforms |
|--------------|-----------|
| `linux/amd64` | Intel, AMD, most cloud VMs |
| `linux/arm64` | Apple Silicon, Raspberry Pi 4+, AWS Graviton |

## Building Locally

```bash
docker build -t n8n-custom .
```

## License

MIT
