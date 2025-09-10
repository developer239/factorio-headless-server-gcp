#!/bin/bash
set -e

echo "Starting Factorio server setup..."

# Update system
apt-get update && apt-get upgrade -y

# Install Docker
apt-get install -y docker.io docker-compose
systemctl enable docker
systemctl start docker

# Create Factorio directory with correct permissions
mkdir -p /opt/factorio/{saves,mods,config,backups}
chown -R 845:845 /opt/factorio  # Factorio container UID

# Create server configuration
cat > /opt/factorio/config/server-settings.json << 'EOF'
{
  "name": "${server_name}",
  "description": "${server_description}",
  "tags": ["gcp", "terraform"],
  "max_players": ${max_players},
  "visibility": {
    "public": false,
    "lan": false
  },%{if game_password != ""}
  "game_password": "${game_password}",%{endif}
  "require_user_verification": false,
  "auto_pause": true,
  "autosave_interval": 10,
  "autosave_slots": 5,
  "only_admins_can_pause_the_game": true,
  "afk_autokick_interval": 30
}
EOF

# Create admin list with configurable admins
cat > /opt/factorio/config/server-adminlist.json << 'EOF'
${jsonencode(admin_users)}
EOF

echo "Starting Factorio Docker container..."

# Pull latest stable Factorio image
docker pull factoriotools/factorio:stable

# Run Factorio container
docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /opt/factorio:/factorio \
  --name factorio \
  --restart=unless-stopped \
  -e GENERATE_NEW_SAVE=true \
  -e SAVE_NAME=terraform-world \
  factoriotools/factorio:stable

# Wait for container to start
sleep 10

# Set up automatic backups every 4 hours
mkdir -p /opt/factorio/backups
cat > /etc/cron.d/factorio-backup << 'EOF'
0 */4 * * * root tar -czf /opt/factorio/backups/backup-$(date +\%Y\%m\%d-\%H\%M\%S).tar.gz /opt/factorio/saves/ 2>/dev/null
EOF

# Clean old backups (keep last 7 days)
cat > /etc/cron.d/factorio-cleanup << 'EOF'
0 2 * * * root find /opt/factorio/backups -name "backup-*.tar.gz" -mtime +7 -delete 2>/dev/null
EOF

# Install basic monitoring tools
apt-get install -y htop iotop

echo "Factorio server setup complete!"
echo "Server will be available at: $(curl -s ifconfig.me):34197"
echo "Check status: docker logs factorio"
echo "Saves location: /opt/factorio/saves/"
echo "Config location: /opt/factorio/config/"

# Show container status
docker ps | grep factorio
