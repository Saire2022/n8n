#!/bin/bash

# n8n Encryption Key Generator
# This script generates secure encryption keys for n8n

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}n8n Encryption Key Generator${NC}"
echo "================================"
echo ""

# Function to generate encryption key
generate_key() {
    openssl rand -base64 24
}

# Function to update .env file
update_env_file() {
    local env_file="$1"
    local key="$2"
    
    if [ -f "$env_file" ]; then
        # Update existing .env file
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s|N8N_ENCRYPTION_KEY=.*|N8N_ENCRYPTION_KEY=$key|" "$env_file"
        else
            # Linux
            sed -i "s|N8N_ENCRYPTION_KEY=.*|N8N_ENCRYPTION_KEY=$key|" "$env_file"
        fi
        echo -e "${GREEN}✓ Updated $env_file${NC}"
    else
        echo -e "${RED}✗ File $env_file not found${NC}"
    fi
}

# Generate keys for different environments
echo -e "${YELLOW}Generating encryption keys...${NC}"
echo ""

# Development key
DEV_KEY=$(generate_key)
echo -e "${BLUE}Development Key:${NC}"
echo "$DEV_KEY"
echo ""

# Staging key
STAGING_KEY=$(generate_key)
echo -e "${BLUE}Staging Key:${NC}"
echo "$STAGING_KEY"
echo ""

# Production key
PROD_KEY=$(generate_key)
echo -e "${BLUE}Production Key:${NC}"
echo "$PROD_KEY"
echo ""

# Ask user what to do
echo -e "${YELLOW}What would you like to do?${NC}"
echo "1) Update .env file with development key"
echo "2) Update .env file with staging key"
echo "3) Update .env file with production key"
echo "4) Create all environment files"
echo "5) Just show the keys (no file updates)"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        update_env_file ".env" "$DEV_KEY"
        ;;
    2)
        update_env_file ".env" "$STAGING_KEY"
        ;;
    3)
        update_env_file ".env" "$PROD_KEY"
        ;;
    4)
        # Create .env file if it doesn't exist
        if [ ! -f ".env" ]; then
            cp env.example .env
            echo -e "${GREEN}✓ Created .env file from template${NC}"
        fi
        
        # Create environment-specific files
        cp env.example .env.staging
        cp env.example .env.production
        
        # Update all files
        update_env_file ".env" "$DEV_KEY"
        update_env_file ".env.staging" "$STAGING_KEY"
        update_env_file ".env.production" "$PROD_KEY"
        
        echo -e "${GREEN}✓ Created all environment files${NC}"
        ;;
    5)
        echo -e "${GREEN}Keys generated successfully!${NC}"
        echo "Copy and paste them manually into your .env files."
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Encryption key generation completed!${NC}"
echo ""
echo -e "${YELLOW}Security Reminders:${NC}"
echo "• Never commit .env files to git"
echo "• Use different keys for each environment"
echo "• Keep your keys secure and private"
echo "• The .env file is already in .gitignore" 