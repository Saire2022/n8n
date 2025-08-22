# n8n Project Management Makefile

.PHONY: help start stop restart status logs export import backup clean dev prod ngrok-start ngrok-stop ngrok-status ngrok-install migrate-postgres postgres-start postgres-stop import-credentials import-credentials-dry

# Default target
help:
	@echo "n8n Project Management Commands:"
	@echo ""
	@echo "Development:"
	@echo "  make dev          - Start development environment"
	@echo "  make start        - Start n8n container"
	@echo "  make stop         - Stop n8n container"
	@echo "  make restart      - Restart n8n container"
	@echo "  make status       - Show container status"
	@echo "  make logs         - Show container logs"
	@echo ""
	@echo "Production:"
	@echo "  make prod         - Start production environment"
	@echo "  make prod-stop    - Stop production environment"
	@echo ""
	@echo "PostgreSQL Migration:"
	@echo "  make migrate-postgres - Migrate from SQLite to PostgreSQL"
	@echo "  make postgres-start   - Start n8n with PostgreSQL"
	@echo "  make postgres-stop    - Stop PostgreSQL setup"
	@echo ""
	@echo "Workflow Management:"
	@echo "  make export       - Export workflows using docker compose exec"
	@echo "  make import       - Import workflows using docker compose exec"
	@echo "  make import-dry   - Dry run import (preview changes)"
	@echo "  make backup       - Create backup of current workflows"
	@echo ""
	@echo "Credential Management:"
	@echo "  make export-credentials - Export credentials with IDs"
	@echo "  make import-credentials - Import credentials from ./credentials"
	@echo "  make import-credentials-dry - Dry run credential import (preview)"
	@echo "  make backup-credentials - Create backup of credentials"
	@echo ""
	@echo "Ngrok (Local Testing):"
	@echo "  make ngrok-start  - Start ngrok tunnel for local testing"
	@echo "  make ngrok-stop   - Stop ngrok tunnel"
	@echo "  make ngrok-status - Show ngrok tunnel status"
	@echo "  make ngrok-install - Show ngrok installation instructions"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean        - Clean up containers and volumes"
	@echo "  make setup        - Initial setup (create .env from example)"
	@echo "  make generate-key - Generate encryption keys for n8n"

# Development environment
dev:
	@echo "Starting development environment..."
	docker compose up -d
	@echo "n8n is running at http://localhost:5678"

start:
	docker compose up -d

stop:
	docker compose down

restart:
	docker compose restart

status:
	docker compose ps

logs:
	docker compose logs -f n8n

# Production environment
prod:
	@echo "Starting production environment..."
	@if [ ! -f .env ]; then \
		echo "Error: .env file not found. Run 'make setup' first."; \
		exit 1; \
	fi
	docker compose -f docker-compose.prod.yml --env-file .env up -d
	@echo "Production n8n is running"

prod-stop:
	docker compose -f docker-compose.prod.yml down

# PostgreSQL Migration
migrate-postgres:
	@echo "Starting migration from SQLite to PostgreSQL..."
	@chmod +x scripts/migrate-to-postgres.sh
	@./scripts/migrate-to-postgres.sh

postgres-start:
	@echo "Starting n8n with PostgreSQL..."
	@if [ ! -f .env ]; then \
		echo "Error: .env file not found. Run 'make setup' first."; \
		exit 1; \
	fi
	docker compose -f docker-compose.postgres.yml --env-file .env up -d
	@echo "n8n with PostgreSQL is running at http://localhost:5678"

postgres-stop:
	@echo "Stopping PostgreSQL setup..."
	docker compose -f docker-compose.postgres.yml down

# Workflow management
export:
	@echo "Exporting workflows using docker compose exec..."
	@if [ -f .env ]; then \
		set -a; \
		source .env 2>/dev/null || true; \
		set +a; \
		./scripts/export-workflows.sh; \
	else \
		echo "Warning: .env file not found, using default values"; \
		./scripts/export-workflows.sh; \
	fi

import:
	@echo "Importing workflows using docker compose exec..."
	@if [ -f .env ]; then \
		set -a; \
		source .env 2>/dev/null || true; \
		set +a; \
		./scripts/import-workflows.sh; \
	else \
		echo "Warning: .env file not found, using default values"; \
		./scripts/import-workflows.sh; \
	fi

import-dry:
	@echo "Dry run import (preview changes)..."
	@if [ -f .env ]; then \
		set -a; \
		source .env 2>/dev/null || true; \
		set +a; \
		DRY_RUN=true ./scripts/import-workflows.sh; \
	else \
		echo "Warning: .env file not found, using default values"; \
		DRY_RUN=true ./scripts/import-workflows.sh; \
	fi

backup:
	@echo "Creating backup..."
	@mkdir -p backups
	@if [ -d workflows ]; then \
		tar -czf backups/workflows_$(shell date +%Y%m%d_%H%M%S).tar.gz workflows/; \
		echo "Backup created: backups/workflows_$(shell date +%Y%m%d_%H%M%S).tar.gz"; \
	else \
		echo "No workflows directory found to backup"; \
	fi

# Credential management
export-credentials:
	@echo "Exporting credentials using docker compose exec..."
	@if [ -f .env ]; then \
		set -a; \
		source .env 2>/dev/null || true; \
		set +a; \
		./scripts/export-credentials.sh; \
	else \
		echo "Warning: .env file not found, using default values"; \
		./scripts/export-credentials.sh; \
	fi

import-credentials:
	@echo "Importing credentials using docker compose exec..."
	@if [ -f .env ]; then \
		set -a; \
		source .env 2>/dev/null || true; \
		set +a; \
		./scripts/import-credentials.sh; \
	else \
		echo "Warning: .env file not found, using default values"; \
		./scripts/import-credentials.sh; \
	fi

import-credentials-dry:
	@echo "Dry run credential import (preview changes)..."
	@if [ -f .env ]; then \
		set -a; \
		source .env 2>/dev/null || true; \
		set +a; \
		DRY_RUN=true ./scripts/import-credentials.sh; \
	else \
		echo "Warning: .env file not found, using default values"; \
		DRY_RUN=true ./scripts/import-credentials.sh; \
	fi

backup-credentials:
	@echo "Creating credentials backup..."
	@mkdir -p backups
	@if [ -d credentials ]; then \
		tar -czf backups/credentials_$(shell date +%Y%m%d_%H%M%S).tar.gz credentials/; \
		echo "Credentials backup created: backups/credentials_$(shell date +%Y%m%d_%H%M%S).tar.gz"; \
	else \
		echo "No credentials directory found to backup"; \
	fi

# Ngrok management
ngrok-start:
	@echo "Starting ngrok tunnel..."
	@if ! command -v ngrok >/dev/null 2>&1; then \
		echo "Error: ngrok is not installed"; \
		echo "Install ngrok from: https://ngrok.com/download"; \
		echo "Then configure your auth token: ngrok config add-authtoken YOUR_TOKEN"; \
		exit 1; \
	fi
	@if ! docker compose ps n8n | grep -q "Up"; then \
		echo "Warning: n8n container is not running. Start it with 'make dev' first."; \
	fi
	@echo "Starting ngrok tunnel for n8n on port 5678..."
	@echo "Access ngrok dashboard at: http://localhost:4040"
	ngrok http 5678

ngrok-stop:
	@echo "Stopping ngrok tunnel..."
	@pkill -f ngrok || echo "No ngrok process found"

ngrok-status:
	@echo "Checking ngrok tunnel status..."
	@if pgrep -f ngrok >/dev/null; then \
		echo "✓ Ngrok tunnel is running"; \
		echo "Dashboard: http://localhost:4040"; \
		if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then \
			echo "Tunnel details:"; \
			curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[] | "  \(.name): \(.public_url)"' 2>/dev/null || echo "  Unable to get tunnel details"; \
		else \
			echo "Install curl and jq to see tunnel details"; \
		fi; \
	else \
		echo "✗ Ngrok tunnel is not running"; \
	fi
	@if docker compose ps n8n | grep -q "Up"; then \
		echo "✓ n8n container is running"; \
	else \
		echo "✗ n8n container is not running"; \
	fi

ngrok-install:
	@echo "Installing ngrok..."
	@if command -v ngrok >/dev/null 2>&1; then \
		echo "✓ ngrok is already installed"; \
		ngrok version; \
		exit 0; \
	fi
	@echo "Please install ngrok manually:"
	@echo "1. Download from: https://ngrok.com/download"
	@echo "2. Follow installation instructions for your OS"
	@echo "3. Configure auth token: ngrok config add-authtoken YOUR_TOKEN"
	@echo ""
	@echo "Or use package managers:"
	@echo "  Ubuntu/Debian: sudo snap install ngrok"
	@echo "  macOS: brew install ngrok/ngrok/ngrok"
	@echo "  Windows: choco install ngrok"

# Maintenance
clean:
	@echo "Cleaning up..."
	docker compose down -v
	docker compose -f docker-compose.prod.yml down -v
	docker compose -f docker-compose.postgres.yml down -v
	docker system prune -f
	@echo "Cleanup completed"

setup:
	@echo "Setting up n8n project..."
	@if [ ! -f .env ]; then \
		cp env.example .env; \
		echo "Created .env file from env.example"; \
		echo "Please edit .env with your configuration"; \
	else \
		echo ".env file already exists"; \
	fi
	@mkdir -p workflows credentials backups
	@echo "Directories created: workflows, credentials, backups"
	@echo "Setup completed. Edit .env file and run 'make dev' to start" 

generate-key:
	@echo "Generating encryption keys for n8n..."
	@chmod +x scripts/generate-encryption-key.sh
	@./scripts/generate-encryption-key.sh 