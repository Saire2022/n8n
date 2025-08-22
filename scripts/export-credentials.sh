#!/bin/bash

# n8n Credentials Export Script (Docker Compose version)
# This script exports credentials from n8n using docker compose exec

set -e

EXPORT_DIR="${EXPORT_DIR:-./credentials}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create directories if they don't exist
mkdir -p "$EXPORT_DIR"
mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}Starting n8n credentials export using Docker Compose...${NC}"

# Check if n8n container is running
if ! docker compose ps n8n | grep -q "Up"; then
    echo -e "${RED}Error: n8n container is not running. Start it with 'make dev' first.${NC}"
    exit 1
fi

# Get the container name
CONTAINER_NAME=$(docker compose ps -q n8n)

# Create a temporary directory inside the container for export
echo -e "${YELLOW}Creating temporary export directory...${NC}"
docker compose exec n8n mkdir -p /tmp/credentials_export

# Export all credentials to the temporary directory with separate files (using IDs)
echo -e "${YELLOW}Exporting credentials to temporary directory...${NC}"
docker compose exec n8n n8n export:credentials --all --separate --output=/tmp/credentials_export/

# Copy the exported files from container to host credentials directory using docker cp
echo -e "${YELLOW}Copying credentials to host directory...${NC}"
docker cp "$CONTAINER_NAME:/tmp/credentials_export/." "$EXPORT_DIR/"

# Clean up temporary directory
docker compose exec n8n rm -rf /tmp/credentials_export

# Create a backup tarball
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
tar -czf "$BACKUP_DIR/credentials_$TIMESTAMP.tar.gz" -C "$EXPORT_DIR" .

echo -e "${GREEN}Export completed!${NC}"
echo -e "Credentials exported to: $EXPORT_DIR"
echo -e "Backup created at: $BACKUP_DIR/credentials_$TIMESTAMP.tar.gz"
echo -e "${YELLOW}Note: Credentials are available in ./credentials on the host.${NC}"
echo -e "${RED}⚠️  WARNING: Credentials contain sensitive data. Do not commit to version control!${NC}"
echo -e "${YELLOW}Files are saved with their IDs as filenames for easy identification.${NC}" 