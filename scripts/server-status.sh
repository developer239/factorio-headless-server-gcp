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

echo -e "${BLUE}Factorio Server Status${NC}"
echo "=================================="

# Check if instance exists
if ! gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE &>/dev/null; then
    echo -e "${RED}Instance '$INSTANCE_NAME' not found in zone '$ZONE'${NC}"
    echo "Make sure you have deployed the infrastructure with Terraform first."
    exit 1
fi

# Get instance details
INSTANCE_INFO=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(status,machineType.scope(machineTypes),networkInterfaces[0].accessConfigs[0].natIP)")
STATUS=$(echo "$INSTANCE_INFO" | cut -d' ' -f1)
MACHINE_TYPE=$(echo "$INSTANCE_INFO" | cut -d' ' -f2 | rev | cut -d'/' -f1 | rev)
EXTERNAL_IP=$(echo "$INSTANCE_INFO" | cut -d' ' -f3)

# Static IP
STATIC_IP=$(gcloud compute addresses describe factorio-server-ip --region=europe-west4 --format="value(address)" 2>/dev/null || echo "N/A")

echo -e "${BLUE}Instance Status:${NC} $STATUS"
echo -e "${BLUE}Machine Type:${NC} $MACHINE_TYPE"
echo -e "${BLUE}External IP:${NC} $EXTERNAL_IP"
echo -e "${BLUE}Static IP:${NC} $STATIC_IP"

if [ "$STATUS" = "RUNNING" ]; then
    echo -e "${GREEN}Instance is running${NC}"

    # Check Docker container status
    echo ""
    echo -e "${BLUE}Docker Container Status:${NC}"

    if gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep factorio" 2>/dev/null; then
        echo -e "${GREEN}Factorio container is running${NC}"

        # Show recent logs
        echo ""
        echo -e "${BLUE}Recent Server Logs (last 10 lines):${NC}"
        gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="docker logs --tail 10 factorio" 2>/dev/null || echo "Could not retrieve logs"

        # Connection info
        echo ""
        echo -e "${GREEN}Connection Information:${NC}"
        echo -e "${GREEN}   Server Address: $STATIC_IP:34197${NC}"
        echo -e "${BLUE}   Players can connect using this address in Factorio${NC}"

    else
        echo -e "${RED}Factorio container is not running${NC}"
        echo -e "${YELLOW}Container may still be starting up...${NC}"
    fi

    # Show resource usage
    echo ""
    echo -e "${BLUE}Resource Usage:${NC}"
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}' | grep factorio" 2>/dev/null || echo "Could not retrieve resource usage"

elif [ "$STATUS" = "TERMINATED" ]; then
    echo -e "${RED}Instance is stopped${NC}"
    echo -e "${BLUE}No compute costs while stopped${NC}"
    echo -e "${BLUE}Start with: ./scripts/start-server.sh${NC}"
else
    echo -e "${YELLOW}Instance status: $STATUS${NC}"
fi

echo ""
echo -e "${BLUE}Available Commands:${NC}"
echo "   ./scripts/start-server.sh  - Start the server"
echo "   ./scripts/stop-server.sh   - Stop the server"
echo "   ./scripts/server-status.sh - Show this status"
