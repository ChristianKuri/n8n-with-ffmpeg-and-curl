ARG N8N_VERSION=latest
FROM docker.n8n.io/n8nio/n8n:${N8N_VERSION}

# Switch to root user to install packages
USER root

# Install ffmpeg, curl, and yt-dlp using Alpine's package manager
RUN apk add --no-cache ffmpeg curl yt-dlp

# Switch back to node user
USER node