ARG N8N_VERSION=latest
FROM docker.n8n.io/n8nio/n8n:${N8N_VERSION}

# Switch to root user to install packages
USER root

# Install ffmpeg, curl, yt-dlp and git.
# Note: The upstream n8n image is Alpine but ships without the `apk` binary,
# so we bootstrap `apk.static` from `apk-tools-static` first.
RUN set -eux; \
  if command -v apk >/dev/null 2>&1; then \
    apk add --no-cache ffmpeg curl yt-dlp git; \
  else \
    ALPINE_REPO="$(head -n 1 /etc/apk/repositories)"; \
    ALPINE_ARCH="$(cat /etc/apk/arch)"; \
    wget -qO /tmp/APKINDEX.tar.gz "${ALPINE_REPO}/${ALPINE_ARCH}/APKINDEX.tar.gz"; \
    APKTOOLS_VER="$(tar -xzO -f /tmp/APKINDEX.tar.gz APKINDEX | awk '$0 == "P:apk-tools-static" {found=1; next} found && /^V:/ {sub(/^V:/, ""); print; exit}')"; \
    if [ -z "${APKTOOLS_VER}" ]; then \
      echo >&2 "Failed to resolve apk-tools-static version from APKINDEX"; \
      exit 1; \
    fi; \
    wget -qO /tmp/apk-tools-static.apk "${ALPINE_REPO}/${ALPINE_ARCH}/apk-tools-static-${APKTOOLS_VER}.apk"; \
    tar -xzf /tmp/apk-tools-static.apk -C /; \
    /sbin/apk.static add --no-cache ffmpeg curl yt-dlp git; \
    rm -f /sbin/apk.static; \
    rm -rf /tmp/* /var/cache/apk/*; \
  fi

# Backup the original n8n entrypoint script
RUN cp /docker-entrypoint.sh /docker-entrypoint-n8n.sh

# Copy our custom entrypoint script that fixes /data permissions
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Switch back to node user
USER node

# Keep the original entrypoint (tini -- /docker-entrypoint.sh)
# Our custom script will be called first, then it calls the original n8n entrypoint