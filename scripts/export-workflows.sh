#!/bin/bash

# n8n Workflow Export Script (Docker Compose version)
# This script exports workflows from n8n using docker compose exec

set -e

EXPORT_DIR="${EXPORT_DIR:-./workflows}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create directories if they don't exist
mkdir -p "$EXPORT_DIR"
mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}Starting n8n workflow export using Docker Compose...${NC}"

# Check if n8n container is running
if ! docker compose ps n8n | grep -q "Up"; then
    echo -e "${RED}Error: n8n container is not running. Start it with 'make dev' first.${NC}"
    exit 1
fi

# Get the container name
CONTAINER_NAME=$(docker compose ps -q n8n)

# Create a temporary directory inside the container for export
echo -e "${YELLOW}Creating temporary export directory...${NC}"
docker compose exec n8n mkdir -p /tmp/workflow_export

# Export all workflows to the temporary directory
echo -e "${YELLOW}Exporting workflows to temporary directory...${NC}"
docker compose exec n8n n8n export:workflow --all --separate --output=/tmp/workflow_export/

# Copy the exported files from container to host workflows directory using docker cp
echo -e "${YELLOW}Copying workflows to host directory...${NC}"
docker cp "$CONTAINER_NAME:/tmp/workflow_export/." "$EXPORT_DIR/"

# Clean up temporary directory
docker compose exec n8n rm -rf /tmp/workflow_export

# Create a backup tarball
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
tar -czf "$BACKUP_DIR/workflows_$TIMESTAMP.tar.gz" -C "$EXPORT_DIR" .

echo -e "${GREEN}Export completed!${NC}"
echo -e "Workflows exported to: $EXPORT_DIR"
echo -e "Backup created at: $BACKUP_DIR/workflows_$TIMESTAMP.tar.gz"
echo -e "${YELLOW}Note: Workflows are available in ./workflows on the host.${NC}" 