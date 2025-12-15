ARG N8N_VERSION=latest
FROM docker.n8n.io/n8nio/n8n:${N8N_VERSION}

# Switch to root user to install packages
USER root

# Install ffmpeg, curl, and yt-dlp using Alpine's package manager
RUN apk add --no-cache ffmpeg curl yt-dlp git

# Backup the original n8n entrypoint script
RUN cp /docker-entrypoint.sh /docker-entrypoint-n8n.sh

# Copy our custom entrypoint script that fixes /data permissions
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Switch back to node user
USER node

# Keep the original entrypoint (tini -- /docker-entrypoint.sh)
# Our custom script will be called first, then it calls the original n8n entrypoint