#!/bin/bash

# Environment Setup Script for infra-flow
# This script ensures the .env file is properly configured
# ALL environment variables must be defined - no fallbacks provided

set -e

# Configuration
ENV_FILE="packages/config/.env"
ENV_EXAMPLE="packages/config/env.example"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    log_info "Creating .env file from template..."
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    log_success "Created $ENV_FILE from template"
    log_error "⚠️  CRITICAL: You MUST update ALL environment variables in $ENV_FILE"
    log_error "    Docker will fail to start if any variables are missing or contain placeholder values"
    echo ""
    echo "Required variables to update:"
    echo "  • POSTGRES_PASSWORD: Change from 'postgres_secure_password_here'"
    echo "  • MINIO_ROOT_PASSWORD: Change from 'minioadmin123_secure_password_here'"  
    echo "  • MINIO_SECRET_KEY: Change from 'minioadmin123_secure_password_here'"
    echo "  • DATABASE_URL: Update with your POSTGRES_PASSWORD"
    echo ""
else
    log_info "Environment file already exists at $ENV_FILE"
fi

# Validate required variables
log_info "Validating environment variables..."

# Check for missing variables
missing_vars=false

# List of required variables
required_vars=(
    "NODE_ENV"
    "POSTGRES_DB"
    "POSTGRES_USER"
    "POSTGRES_PASSWORD"
    "MINIO_ROOT_USER"
    "MINIO_ROOT_PASSWORD"
    "DATABASE_URL"
    "PORT"
    "MINIO_ENDPOINT"
    "MINIO_ACCESS_KEY"
    "MINIO_SECRET_KEY"
    "NEXT_PUBLIC_API_URL"
    "NEXT_PUBLIC_TRPC_URL"
)

for var in "${required_vars[@]}"; do
    if ! grep -q "^$var=" "$ENV_FILE"; then
        log_error "❌ Missing required variable: $var"
        missing_vars=true
    fi
done

# Check for placeholder values
if grep -q "postgres_secure_password_here" "$ENV_FILE"; then
    log_error "❌ Default PostgreSQL password detected! Please update POSTGRES_PASSWORD in $ENV_FILE"
    missing_vars=true
fi

if grep -q "minioadmin123_secure_password_here" "$ENV_FILE"; then
    log_error "❌ Default MinIO password detected! Please update MINIO_ROOT_PASSWORD and MINIO_SECRET_KEY in $ENV_FILE"
    missing_vars=true
fi

if [ "$missing_vars" = true ]; then
    log_error "❌ SETUP INCOMPLETE: Environment file has missing or placeholder values"
    log_error "    Docker containers will fail to start until all variables are properly configured"
    echo ""
    echo "Next steps:"
    echo "  1. Edit $ENV_FILE and replace ALL placeholder values"
    echo "  2. Run this script again to validate: npm run setup:env"
    echo "  3. Start services: npm run dev"
    exit 1
fi

log_success "✅ All environment variables are properly configured!"
echo ""
echo "Ready to start services:"
echo "  • Development: npm run dev"
echo "  • Production: npm run start" 