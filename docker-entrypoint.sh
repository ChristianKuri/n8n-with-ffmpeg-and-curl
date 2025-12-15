#!/bin/sh
set -e

# Fix /data directory permissions if needed
# This ensures the node user (UID 1000) can write to /data even if the host mount
# is owned by a different user or root
if [ -d "/data" ]; then
    # Get node user UID/GID (typically 1000:1000)
    NODE_UID=$(id -u node 2>/dev/null || echo "1000")
    NODE_GID=$(id -g node 2>/dev/null || echo "1000")
    
    # Get current ownership of /data
    CURRENT_UID=$(stat -c '%u' /data 2>/dev/null || stat -f '%u' /data 2>/dev/null || echo "")
    CURRENT_GID=$(stat -c '%g' /data 2>/dev/null || stat -f '%g' /data 2>/dev/null || echo "")
    
    # Check if node user owns the directory or can write to it
    if [ -z "$CURRENT_UID" ] || [ "$CURRENT_UID" != "$NODE_UID" ] || [ "$CURRENT_GID" != "$NODE_GID" ]; then
        # Also check if node user can actually write (in case of group permissions)
        if ! su-exec node test -w /data 2>/dev/null; then
            echo "Fixing /data permissions for node user (UID ${NODE_UID}:GID ${NODE_GID})..."
            
            # Change ownership to node:node
            chown -R "${NODE_UID}:${NODE_GID}" /data
            
            # Ensure directory has proper permissions
            chmod 755 /data
            
            echo "/data permissions fixed (owned by UID ${NODE_UID}:GID ${NODE_GID})"
        fi
    fi
fi

# Execute the original n8n entrypoint script
# We backed it up to /docker-entrypoint-n8n.sh in the Dockerfile
exec /docker-entrypoint-n8n.sh "$@"

