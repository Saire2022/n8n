#!/bin/bash

# n8n Credentials Import Script (Docker Compose version)
# This script imports credentials into n8n using docker compose exec

set -e

IMPORT_DIR="${IMPORT_DIR:-./credentials}"
DRY_RUN="${DRY_RUN:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting n8n credentials import using Docker Compose...${NC}"

# Check if n8n container is running
if ! docker compose ps n8n | grep -q "Up"; then
    echo -e "${RED}Error: n8n container is not running. Start it with 'make dev' first.${NC}"
    exit 1
fi

# Check if credentials directory exists and has files
if [ ! -d "$IMPORT_DIR" ]; then
    echo -e "${RED}Error: Credentials directory '$IMPORT_DIR' not found.${NC}"
    echo -e "${YELLOW}Run 'make export-credentials' first to export credentials from n8n.${NC}"
    exit 1
fi

# Count credential files
CREDENTIAL_FILES=$(find "$IMPORT_DIR" -name "*.json" -type f | wc -l)
if [ "$CREDENTIAL_FILES" -eq 0 ]; then
    echo -e "${RED}Error: No credential files found in '$IMPORT_DIR'.${NC}"
    echo -e "${YELLOW}Run 'make export-credentials' first to export credentials from n8n.${NC}"
    exit 1
fi

echo -e "${BLUE}Found $CREDENTIAL_FILES credential files to import.${NC}"

# Get the container name
CONTAINER_NAME=$(docker compose ps -q n8n)

# Create a temporary directory inside the container for import
echo -e "${YELLOW}Creating temporary import directory...${NC}"
docker compose exec n8n mkdir -p /tmp/credentials_import

# Copy credential files from host to container
echo -e "${YELLOW}Copying credentials to container...${NC}"
docker cp "$IMPORT_DIR/." "$CONTAINER_NAME:/tmp/credentials_import/"

if [ "$DRY_RUN" = "true" ]; then
    echo -e "${BLUE}DRY RUN MODE - Previewing credentials to be imported:${NC}"
    docker compose exec n8n ls -la /tmp/credentials_import/
    echo -e "${YELLOW}Dry run completed. No credentials were actually imported.${NC}"
    echo -e "${BLUE}To perform actual import, run without DRY_RUN=true${NC}"
else
    # Import each credential file individually
    echo -e "${YELLOW}Importing credentials one by one...${NC}"
    imported_count=0
    failed_count=0
    failed_files=()
    
    # Temporarily disable set -e for the import loop
    set +e
    
    for file in "$IMPORT_DIR"/*.json; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo -e "${BLUE}Importing: $filename${NC}"
            
            # Create a temporary file with the credential wrapped in an array
            temp_file="/tmp/credentials_import/temp_$filename"
            docker compose exec n8n sh -c "echo '[' > $temp_file && cat /tmp/credentials_import/$filename >> $temp_file && echo ']' >> $temp_file"
            
            # Import the temporary file with array format
            if docker compose exec n8n n8n import:credentials --input="$temp_file" 2>/dev/null; then
                echo -e "${GREEN}✓ Successfully imported: $filename${NC}"
                ((imported_count++))
            else
                echo -e "${RED}✗ Failed to import: $filename${NC}"
                ((failed_count++))
                failed_files+=("$filename")
            fi
            
            # Clean up temporary file
            docker compose exec n8n rm -f "$temp_file"
        fi
    done
    
    # Re-enable set -e
    set -e
    
    echo ""
    echo -e "${GREEN}Import completed!${NC}"
    echo -e "${BLUE}Successfully imported: $imported_count out of $CREDENTIAL_FILES credential files.${NC}"
    
    if [ $failed_count -gt 0 ]; then
        echo -e "${RED}Failed to import: $failed_count credential files.${NC}"
        echo -e "${YELLOW}Failed files:${NC}"
        for failed_file in "${failed_files[@]}"; do
            echo -e "${RED}  - $failed_file${NC}"
        done
        echo -e "${YELLOW}Note: Failed imports may be due to unsupported credential types or format issues.${NC}"
    fi
    
    echo -e "${YELLOW}Note: Existing credentials with the same ID will be updated.${NC}"
fi

# Clean up temporary directory
docker compose exec n8n rm -rf /tmp/credentials_import

echo -e "${GREEN}Credential import process finished!${NC}" 