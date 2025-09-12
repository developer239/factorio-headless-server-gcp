#!/bin/bash
set -e

echo "Starting Factorio server setup..."

# Update system
echo "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install Docker (idempotent)
echo "Installing Docker..."
apt-get install -y docker.io docker-compose
systemctl enable docker
systemctl start docker

# Verify Docker is running
if systemctl is-active --quiet docker; then
    echo "✅ Docker is running"
else
    echo "❌ Docker failed to start"
    systemctl status docker --no-pager
    exit 1
fi

# Create Factorio directory with correct permissions (idempotent)
echo "Setting up Factorio directories..."
mkdir -p /factorio/{saves,mods,config,backups}
chown -R 845:845 /factorio  # Factorio container UID
echo "Factorio directories ready"

# No need for manual configuration - wrapped image handles it via environment variables
echo "Configuration will be handled by wrapped image via environment variables"

echo "Managing existing Factorio container..."

# Check if container exists and stop it gracefully
if docker ps -a --format '{{.Names}}' | grep -q "^factorio$"; then
    echo "Found existing Factorio container, stopping gracefully..."

    # Stop container gracefully (allows auto-save)
    docker stop factorio 2>/dev/null || echo "Container was not running"

    # Wait for graceful shutdown
    sleep 5

    # Remove container (but keep volumes/data)
    docker rm factorio 2>/dev/null || echo "Container already removed"

    echo "Existing container cleaned up"
else
    echo "No existing container found"
fi

echo "Starting Factorio Docker container with HTTP controls..."

# Pull Factorio image with HTTP controls
docker pull jarnotmichal/factorio-with-http-controls:2.0.55

# Run Factorio container with HTTP API
docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -p 8080:8080/tcp \
  -v /factorio:/factorio \
  --name factorio \
  --restart=unless-stopped \
  -e FACTORIO_SERVER_NAME="${server_name}" \
  -e FACTORIO_SERVER_DESCRIPTION="${server_description}" \
  -e FACTORIO_MAX_PLAYERS=${max_players} \
  -e FACTORIO_ADMIN_USERS='${jsonencode(admin_users)}' \
  -e FACTORIO_SAVE_NAME=default \
  jarnotmichal/factorio-with-http-controls:2.0.55

# Wait for container to start
sleep 10

echo "Verifying container startup..."
if docker ps | grep -q factorio; then
    echo "✅ Factorio container is running"
    docker logs factorio --tail 5 2>/dev/null || echo "Container logs not yet available"
else
    echo "❌ Container failed to start, checking logs..."
    docker logs factorio --tail 10 2>/dev/null || echo "No logs available"
    echo "Container status:"
    docker ps -a | grep factorio || echo "No factorio container found"
fi

# Set up automatic backups every 4 hours (idempotent)
echo "Setting up automatic backups..."
mkdir -p /factorio/backups

# Create backup cron job (overwrite existing) - daily at 2 AM
cat > /etc/cron.d/factorio-backup << 'EOF'
0 2 * * * root tar -czf /factorio/backups/backup-$(date +\%Y\%m\%d-\%H\%M\%S).tar.gz /factorio/saves/ 2>/dev/null
EOF

# Clean old backups (keep last 7 days)
cat > /etc/cron.d/factorio-cleanup << 'EOF'
0 2 * * * root find /factorio/backups -name "backup-*.tar.gz" -mtime +7 -delete 2>/dev/null
EOF

echo "Backup system configured"

# Install basic monitoring tools (idempotent)
echo "Installing monitoring tools..."
apt-get install -y htop iotop

echo "Factorio server setup complete!"

# Get external IP for connection info
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to determine external IP")
echo "Server will be available at: $EXTERNAL_IP:34197"
echo "HTTP API will be available at: http://$EXTERNAL_IP:8080"

echo "Management commands:"
echo "  Check status: docker logs factorio"
echo "  Container stats: docker stats factorio --no-stream"
echo "  Restart container: docker restart factorio"
echo "  HTTP API status: curl http://$EXTERNAL_IP:8080/factorio/status"

echo "File locations:"
echo "  Saves: /factorio/saves/"
echo "  Config: /factorio/config/"
echo "  Backups: /factorio/backups/"

echo "Final container status:"
docker ps | grep factorio || echo "Warning: Factorio container not visible in running processes"
