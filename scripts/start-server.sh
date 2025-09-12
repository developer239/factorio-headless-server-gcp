#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values (can be overridden)
INSTANCE_NAME="factorio-server"
ZONE="europe-west4-a"

echo -e "${BLUE}Starting Factorio server...${NC}"

# Check if instance exists
if ! gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE &>/dev/null; then
    echo -e "${RED}Instance '$INSTANCE_NAME' not found in zone '$ZONE'${NC}"
    echo "Make sure you have deployed the infrastructure with Terraform first."
    exit 1
fi

# Get current instance status
STATUS=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(status)")

if [ "$STATUS" = "RUNNING" ]; then
    echo -e "${GREEN}Server is already running!${NC}"

    # Get the IP address
    IP=$(gcloud compute addresses describe factorio-server-ip --region=europe-west4 --format="value(address)")
    echo -e "${GREEN}Connect to: $IP:34197${NC}"
    echo -e "${GREEN}HTTP API: http://$IP:8080${NC}"
    exit 0
fi

echo -e "${BLUE}Starting instance...${NC}"
gcloud compute instances start $INSTANCE_NAME --zone=$ZONE

echo -e "${BLUE}Waiting for server to be ready...${NC}"
sleep 60

# Get the IP address
IP=$(gcloud compute addresses describe factorio-server-ip --region=europe-west4 --format="value(address)")

echo -e "${GREEN}Factorio server is now running!${NC}"
echo -e "${GREEN}Players can connect to: $IP:34197${NC}"
echo -e "${GREEN}HTTP API available at: http://$IP:8080${NC}"
echo -e "${BLUE}Check server status: curl http://$IP:8080/factorio/status${NC}"
echo -e "${BLUE}Stop server: ./scripts/stop-server.sh${NC}"
