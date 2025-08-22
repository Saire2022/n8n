#!/bin/bash

# n8n Workflow Import Script (Docker Compose version)
# This script imports workflows to n8n using docker compose exec

set -e

IMPORT_DIR="${IMPORT_DIR:-./workflows}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting n8n workflow import using Docker Compose...${NC}"

# Check if n8n container is running
if ! docker compose ps n8n | grep -q "Up"; then
    echo -e "${RED}Error: n8n container is not running. Start it with 'make dev' first.${NC}"
    exit 1
fi

# Check if import directory exists
if [ ! -d "$IMPORT_DIR" ]; then
    echo -e "${RED}Error: Import directory $IMPORT_DIR does not exist${NC}"
    exit 1
fi

# Check if this is a dry run
if [ "$DRY_RUN" = "true" ]; then
    echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
    echo -e "${BLUE}Workflows to be imported:${NC}"
    find "$IMPORT_DIR" -name "*.json" -type f | while read -r file; do
        echo -e "  - $(basename "$file")"
    done
    echo -e "${YELLOW}To actually import, run without DRY_RUN=true${NC}"
    exit 0
fi

# Import all workflow files from the directory using docker compose exec
echo -e "${YELLOW}Importing workflows from: $IMPORT_DIR${NC}"
docker compose exec n8n n8n import:workflow --separate --input=/home/node/.n8n/workflows

echo -e "${GREEN}Import completed!${NC}"
echo -e "Workflows imported from: $IMPORT_DIR" 