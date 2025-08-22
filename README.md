# n8n Workflow Automation Project

This repository contains a complete setup for managing n8n workflows with version control, multiple environments, and automated deployment.

## 🚀 Quick Start

1. **Setup the project:**
   ```bash
   make setup
   ```

2. **Configure environment:**
   Edit the `.env` file with your settings

3. **Start development environment:**
   ```bash
   make dev
   ```

4. **Access n8n:**
   Open http://localhost:5678 in your browser

## 📁 Project Structure

```
├── docker-compose.yml          # Development environment
├── docker-compose.prod.yml     # Production environment
├── env.example                 # Environment variables template
├── .gitignore                  # Git ignore rules
├── Makefile                    # Project management commands
├── scripts/
│   ├── export-workflows.sh     # Export workflows from n8n
│   ├── import-workflows.sh     # Import workflows to n8n
│   ├── export-credentials.sh   # Export credentials from n8n
│   ├── import-credentials.sh   # Import credentials to n8n
│   └── generate-encryption-key.sh # Generate encryption keys
├── workflows/                  # Version controlled workflows
├── credentials/                # Credential templates (not in git)
└── backups/                    # Workflow backups
```

## 🔧 Environment Management

### Development Environment
- Uses `docker-compose.yml`
- Basic authentication enabled
- Local data persistence
- Debug logging enabled

### Production Environment
- Uses `docker-compose.prod.yml`
- Enhanced security settings
- Resource limits configured
- SMTP email notifications
- Optimized performance settings

## 📋 Available Commands

### Development
```bash
make dev          # Start development environment
make start        # Start n8n container
make stop         # Stop n8n container
make restart      # Restart n8n container
make status       # Show container status
make logs         # Show container logs
```

### Production
```bash
make prod         # Start production environment
make prod-stop    # Stop production environment
```

### Workflow Management
```bash
make export       # Export workflows using docker compose exec
make import       # Import workflows using docker compose exec
make import-dry   # Dry run import (preview changes)
make backup       # Create backup of current workflows
```

### Credential Management
```bash
make export-credentials       # Export credentials with IDs
make import-credentials       # Import credentials from ./credentials
make import-credentials-dry   # Dry run credential import (preview)
make backup-credentials       # Create backup of credentials
```

## 🔐 Credential Management

### Overview
Credentials in n8n contain sensitive information like API keys, database passwords, and authentication tokens. This project provides tools to safely export, import, and backup credentials across different environments.

### Exporting Credentials
Export credentials from your n8n instance to version control:

```bash
make export-credentials
```

This will:
- Export all credentials as individual JSON files
- Save them to the `./credentials/` directory
- Create timestamped backups in `./backups/`
- Use credential IDs as filenames for easy identification

**Example output:**
```
Starting n8n credentials export using Docker Compose...
Creating temporary export directory...
Exporting credentials to temporary directory...
Successfully exported 6 credentials.
Copying credentials to host directory...
Export completed!
Credentials exported to: ./credentials
Backup created at: ./backups/credentials_20250716_110808.tar.gz
```

### Importing Credentials
Import credentials into your n8n instance:

```bash
make import-credentials
```

For a preview of what would be imported without actually importing:
```bash
make import-credentials-dry
```

**Example output:**
```
Starting n8n credentials import using Docker Compose...
Found 6 credential files to import.
Creating temporary import directory...
Copying credentials to container...
Importing credentials one by one...
Importing: 10iPbAzQofF4phVg.json
✓ Successfully imported: 10iPbAzQofF4phVg.json
...
Import completed!
Successfully imported: 6 out of 6 credential files.
```

### Credential File Structure
Each credential is exported as a separate JSON file with the following structure:

```json
{
  "createdAt": "2025-07-15T16:03:10.202Z",
  "updatedAt": "2025-07-15T16:03:27.821Z",
  "id": "10iPbAzQofF4phVg",
  "name": "Postgres account",
  "data": "U2FsdGVkX19UeMCP0GqIhscd1T0y9WIT48BpC0QU+wCbonrgURYxiVcWjc+VIMWFPZpb/csQOmBTattjat1Tr/SZLdi94Hrq5NIx2H2EBmyBxin2iJeXhudSS361WcHPDiKisY42A6urySarFHC4maSSKfcdN8HnCS9S8R6sVYg=",
  "type": "postgres",
  "isManaged": false
}
```

### Credential Types Supported
The system supports various credential types including:
- **Database connections** (PostgreSQL, MySQL, etc.)
- **API integrations** (WhatsApp, Google APIs, etc.)
- **Custom authentication** (HTTP Basic Auth, OAuth, etc.)
- **Cloud services** (AWS, Google Cloud, etc.)

### Backup and Restore
Create timestamped backups of your credentials:

```bash
make backup-credentials
```

This creates a compressed backup in the `./backups/` directory:
```
Credentials backup created: ./backups/credentials_20250716_110808.tar.gz
```

### Security Best Practices

#### ✅ Safe Practices
- **Export credentials** before making changes in n8n UI
- **Use dry-run mode** to preview imports before applying
- **Create regular backups** of your credentials
- **Test imports** in development before production
- **Use different credentials** for each environment

#### ❌ Security Risks
- **Never commit** credential files to git
- **Don't share** credential files publicly
- **Avoid storing** credentials in plain text
- **Don't use** production credentials in development

#### Git Workflow for Credentials
1. **Export credentials** after creating/updating in n8n UI
2. **Review changes** using `make import-credentials-dry`
3. **Commit credential files** to version control (if safe for your team)
4. **Import credentials** on other environments
5. **Create backups** before major changes

### Troubleshooting Credentials

#### Common Issues

1. **Import fails with "File does not seem to contain credentials":**
   - Ensure credential files are in correct JSON format
   - Check that files contain valid credential data
   - Verify n8n version compatibility

2. **Some credentials don't appear after import:**
   - Check if credential type is supported by your n8n instance
   - Verify community nodes are installed for custom credential types
   - Look for import errors in the output

3. **Permission denied errors:**
   - Ensure n8n container is running: `make status`
   - Check file permissions in credentials directory
   - Verify Docker container access

4. **Duplicate credential IDs:**
   - Existing credentials with same ID will be updated
   - Check for conflicts before importing
   - Use dry-run mode to preview changes

#### Manual Credential Operations
If you need to work with credentials manually:

```bash
# Export specific credential
docker compose exec n8n n8n export:credentials --id=CREDENTIAL_ID

# Import specific credential file
docker compose exec n8n n8n import:credentials --input=/path/to/credential.json

# List all credentials in n8n
docker compose exec n8n n8n list:credentials
```

### Environment-Specific Credentials
For multi-environment setups, consider organizing credentials by environment:

```
credentials/
├── development/
│   ├── postgres-dev.json
│   └── api-dev.json
├── staging/
│   ├── postgres-staging.json
│   └── api-staging.json
└── production/
    ├── postgres-prod.json
    └── api-prod.json
```

This allows you to import environment-specific credentials:
```bash
IMPORT_DIR=./credentials/development make import-credentials
```

### Ngrok (Local Testing)
```bash
make ngrok-start  # Start ngrok tunnel for local testing
make ngrok-stop   # Stop ngrok tunnel
make ngrok-status # Show ngrok tunnel status
```

### Maintenance
```bash
make clean        # Clean up containers and volumes
make setup        # Initial setup (create .env from example)
make generate-key # Generate encryption keys for n8n
```

## 🔄 Workflow Version Control

### Exporting Workflows
Workflows are exported using docker compose exec to the container's workflow directory:

```bash
make export
```

This will:
- Connect to your n8n container using `docker compose exec n8n n8n export:workflow --all --separate --output=/home/node/.n8n/workflows/`
- Export all workflows as individual JSON files
- Create backups with timestamps
- Generate a summary README

### Importing Workflows
Import workflows from version control:

```bash
make import
```

For a preview of changes without applying them:
```bash
make import-dry
```

### Git Workflow
1. **Export workflows** after making changes in n8n UI
2. **Commit changes** to git with descriptive messages
3. **Push to repository** to share with team
4. **Import workflows** on other environments

## 🔐 Encryption Key Management

### Generating Encryption Keys
n8n requires a secure encryption key for data protection. Generate one using:

```bash
make generate-key
```

This will:
- Generate secure 32-character encryption keys
- Create different keys for development, staging, and production
- Optionally update your `.env` files automatically
- Provide an interactive menu for key management

### Manual Key Generation
If you prefer to generate keys manually:

```bash
# Generate a single key
openssl rand -base64 24

# Or use the script directly
./scripts/generate-encryption-key.sh
```

### Security Best Practices
- **Use different keys** for each environment (dev, staging, prod)
- **Never commit** encryption keys to git
- **Keep keys secure** and private
- **Rotate keys** periodically in production
- **Backup keys** securely (you'll need them to decrypt data)

## 🌐 Ngrok Integration for Local Testing

### Prerequisites
Before using ngrok, you need to install it first:

1. **Install ngrok** from [https://ngrok.com/download](https://ngrok.com/download)
2. **Get your auth token** from [https://dashboard.ngrok.com/get-started/your-authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)
3. **Configure your auth token**:
   ```bash
   ngrok config add-authtoken your_auth_token_here
   ```

### Quick Start
The simplest way to expose your local n8n instance:

```bash
# Start n8n first
make dev

# In another terminal, start ngrok tunnel
ngrok http 5678
```

### Using Makefile Commands
```bash
# Start ngrok tunnel
make ngrok-start

# Check tunnel status
make ngrok-status

# Stop tunnel
make ngrok-stop
```

### Manual Ngrok Commands
If you prefer to use ngrok directly:

```bash
# Basic tunnel (most common)
ngrok http 5678

# Configure auth token
ngrok config add-authtoken your_auth_token_here

# Start tunnel with custom domain
ngrok http --domain=your-domain.ngrok.io 5678

# Start tunnel in specific region
ngrok http --region=us 5678
```

### Ngrok Dashboard
- Access ngrok dashboard at: http://localhost:4040
- View tunnel details and inspect requests
- Monitor traffic and debug webhooks

### Documentation
- [Ngrok Installation Guide](https://ngrok.com/docs/getting-started/install)
- [Ngrok Configuration](https://ngrok.com/docs/getting-started/setup)
- [Ngrok Dashboard](https://ngrok.com/docs/using-ngrok/dashboard)

## 🔐 Security Considerations

### What to Commit to Git
✅ **Safe to commit:**
- Workflow JSON files (without sensitive data)
- Docker configuration files
- Scripts and documentation
- Environment variable templates

❌ **Never commit:**
- `.env` files with real credentials
- Database files (SQLite)
- Credential files
- API keys and secrets
- Ngrok auth tokens

### Environment Variables
Create a `.env` file from the template:
```bash
cp env.example .env
```

Key variables to configure:
- `N8N_USER` / `N8N_PASSWORD` - Authentication
- `N8N_ENCRYPTION_KEY` - Data encryption
- `WEBHOOK_URL` - Webhook endpoint
- `NGROK_AUTH_TOKEN` - Ngrok authentication (for local testing)
- SMTP settings for production

## 🌍 Multi-Environment Setup

### Development
```bash
make dev
```
- Local development
- Debug mode
- Basic authentication

### Staging
```bash
# Create staging environment file
cp env.example .env.staging
# Edit .env.staging with staging settings
docker-compose -f docker-compose.yml --env-file .env.staging up -d
```

### Production
```bash
make prod
```
- Production-optimized settings
- Resource limits
- Email notifications
- Enhanced security

## 📊 Monitoring and Logs

### View Logs
```bash
make logs
```

### Container Status
```bash
make status
```

### Backup Workflows
```bash
make backup
```

## 🔧 Troubleshooting

### Common Issues

1. **Container won't start:**
   ```bash
   make clean
   make setup
   make dev
   ```

2. **Workflow export fails:**
   - Check n8n is running: `make status`
   - Verify container is accessible: `docker compose ps`
   - Try manual export: `docker compose exec n8n n8n export:workflow --all --separate --output=/home/node/.n8n/workflows/`

3. **Ngrok tunnel issues:**
   - Verify ngrok is installed: `ngrok version`
   - Check auth token is configured
   - Ensure n8n container is running before starting tunnel
   - Check ngrok dashboard at http://localhost:4040

4. **Port conflicts:**
   - Change port in `docker-compose.yml`
   - Update `N8N_PORT` in `.env`

### Reset Everything
```bash
make clean
make setup
make dev
```

## 🤝 Contributing

1. Export workflows before making changes
2. Make changes in n8n UI
3. Export workflows again
4. Commit changes with descriptive messages
5. Push to repository

## 📚 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Docker Guide](https://docs.n8n.io/hosting/installation/docker/)
- [n8n API Reference](https://docs.n8n.io/api/)
- [Ngrok Documentation](https://ngrok.com/docs)

## 📄 License

This project is licensed under the MIT License.
