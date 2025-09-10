#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values (can be overridden)
INSTANCE_NAME="factorio-server"
ZONE="europe-west4-a"

echo -e "${BLUE}Stopping Factorio server...${NC}"

# Check if instance exists
if ! gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE &>/dev/null; then
    echo -e "${RED}Instance '$INSTANCE_NAME' not found in zone '$ZONE'${NC}"
    exit 1
fi

# Get current instance status
STATUS=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(status)")

if [ "$STATUS" = "TERMINATED" ]; then
    echo -e "${GREEN}Server is already stopped.${NC}"
    exit 0
fi

if [ "$STATUS" != "RUNNING" ]; then
    echo -e "${YELLOW}Server status: $STATUS${NC}"
    echo "Server is not in a normal running state. Attempting to stop anyway..."
fi

# Factorio auto-saves every 10 minutes, so manual save is not required
echo -e "${BLUE}Factorio auto-saves when server stops${NC}"

# Stop the instance
echo -e "${BLUE}Stopping instance...${NC}"
gcloud compute instances stop $INSTANCE_NAME --zone=$ZONE

echo -e "${GREEN}Factorio server stopped successfully!${NC}"
echo -e "${BLUE}Server costs stopped - you're now only paying for disk storage${NC}"
echo -e "${BLUE}Restart server: ./scripts/start-server.sh${NC}"
