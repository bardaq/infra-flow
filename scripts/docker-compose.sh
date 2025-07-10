#!/bin/bash

# Docker Compose Management Script for infra-flow
# Usage: ./docker-compose.sh [command]

set -e

# Configuration
COMPOSE_FILE="packages/config/docker/docker-compose.yml"
COMPOSE_DIR="packages/config"
ENV_FILE="packages/config/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Setup environment file
setup_env() {
    if [ ! -f "$ENV_FILE" ]; then
        log_info "Creating environment file from template..."
        cp "$COMPOSE_DIR/env.example" "$ENV_FILE"
        log_warn "Please update the environment variables in $ENV_FILE"
    fi
}

# Show help
show_help() {
    echo "Docker Compose Management Script for infra-flow"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  up          Start all services (uses NODE_ENV from .env)"
    echo "  down        Stop all services"
    echo "  restart     Restart all services"
    echo "  build [dev|prod]  Build all images (optionally for dev/prod)"
    echo "  rebuild [dev|prod]  Rebuild all images without cache (optionally for dev/prod)"
    echo "  logs        Show logs for all services"
    echo "  logs [svc]  Show logs for specific service"
    echo "  ps          Show running containers"
    echo "  shell [svc] Open shell in service container"
    echo "  clean       Remove all containers, networks, and volumes"
    echo "  dev         Start in development mode (NODE_ENV=development)"
    echo "  prod        Start in production mode (NODE_ENV=production)"
    echo "  setup       Setup environment file"
    echo "  help        Show this help message"
    echo ""
    echo "Services: postgres, minio, api, web, prisma-studio"
}

# Main commands
case "${1:-help}" in
    "up")
        check_docker
        setup_env
        log_info "Starting all services..."
        # Use override file if available (includes prisma-studio)
        if [ -f "packages/config/docker/docker-compose.override.yml" ]; then
            docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" up -d
            log_success "All services started successfully!"
            log_info "Web app: http://localhost:3000"
            log_info "API: http://localhost:2022"
            log_info "MinIO Console: http://localhost:9001"
            log_info "Prisma Studio: http://localhost:5555"
        else
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
            log_success "All services started successfully!"
            log_info "Web app: http://localhost:3000"
            log_info "API: http://localhost:2022"
            log_info "MinIO Console: http://localhost:9001"
        fi
        ;;
    
    "down")
        check_docker
        log_info "Stopping all services..."
        # Try to stop with override file first (includes prisma-studio)
        if [ -f "packages/config/docker/docker-compose.override.yml" ]; then
            docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" down --remove-orphans
        else
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down --remove-orphans
        fi
        log_success "All services stopped successfully!"
        ;;
    
    "restart")
        check_docker
        log_info "Restarting all services..."
        # Restart with override file if it exists (includes prisma-studio)
        if [ -f "packages/config/docker/docker-compose.override.yml" ]; then
            docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" restart
        else
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" restart
        fi
        log_success "All services restarted successfully!"
        ;;
    
    "build")
        check_docker
        log_info "Building all images..."
        if [ -n "$2" ] && [ "$2" = "dev" ]; then
            log_info "Building for development environment..."
            NODE_ENV=development docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" build
        elif [ -n "$2" ] && [ "$2" = "prod" ]; then
            log_info "Building for production environment..."
            NODE_ENV=production docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build
        else
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build
        fi
        log_success "All images built successfully!"
        ;;
    
    "rebuild")
        check_docker
        log_info "Rebuilding all images without cache..."
        if [ -n "$2" ] && [ "$2" = "dev" ]; then
            log_info "Rebuilding for development environment..."
            NODE_ENV=development docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" build --no-cache
        elif [ -n "$2" ] && [ "$2" = "prod" ]; then
            log_info "Rebuilding for production environment..."
            NODE_ENV=production docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build --no-cache
        else
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build --no-cache
        fi
        log_success "All images rebuilt successfully!"
        ;;
    
    "logs")
        check_docker
        if [ -n "$2" ]; then
            log_info "Showing logs for service: $2"
            # Try with override file first (includes prisma-studio)
            if [ -f "packages/config/docker/docker-compose.override.yml" ]; then
                docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" logs -f "$2"
            else
                docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" logs -f "$2"
            fi
        else
            log_info "Showing logs for all services..."
            # Try with override file first (includes prisma-studio)
            if [ -f "packages/config/docker/docker-compose.override.yml" ]; then
                docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" logs -f
            else
                docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" logs -f
            fi
        fi
        ;;
    
    "ps")
        check_docker
        log_info "Showing running containers..."
        # Show all services including prisma-studio if available
        if [ -f "packages/config/docker/docker-compose.override.yml" ]; then
            docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" ps
        else
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps
        fi
        ;;
    
    "shell")
        check_docker
        if [ -n "$2" ]; then
            log_info "Opening shell in service: $2"
            # Try with override file first (includes prisma-studio)
            if [ -f "packages/config/docker/docker-compose.override.yml" ]; then
                docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" exec "$2" /bin/sh
            else
                docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" exec "$2" /bin/sh
            fi
        else
            log_error "Please specify a service name"
            exit 1
        fi
        ;;
    
    "clean")
        check_docker
        log_warn "This will remove all containers, networks, and volumes!"
        read -p "Are you sure? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Cleaning up Docker environment..."
            # Clean with override file first (includes prisma-studio)
            if [ -f "packages/config/docker/docker-compose.override.yml" ]; then
                docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" down -v --rmi all --remove-orphans
            else
                docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down -v --rmi all --remove-orphans
            fi
            log_success "Docker environment cleaned successfully!"
        else
            log_info "Operation cancelled."
        fi
        ;;
    
    "dev")
        check_docker
        setup_env
        log_info "Starting in development mode with HMR..."
        NODE_ENV=development docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" up -d
        log_success "Development environment started successfully!"
        log_info "Web app: http://localhost:3000 (with HMR)"
        log_info "API: http://localhost:2022 (with HMR)"
        log_info "MinIO Console: http://localhost:9001"
        log_info "Prisma Studio: http://localhost:5555"
        log_info "HMR is enabled for:"
        log_info "  - Next.js web app changes"
        log_info "  - API server changes"
        log_info "  - UI package changes"
        ;;
    
    "prod")
        check_docker
        setup_env
        log_info "Starting in production mode..."
        NODE_ENV=production docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
        log_success "Production environment started successfully!"
        log_info "Web app: http://localhost:3000"
        log_info "API: http://localhost:2022"
        log_info "MinIO Console: http://localhost:9001"
        ;;
    
    "setup")
        setup_env
        log_success "Environment file setup completed!"
        ;;
    
    "help")
        show_help
        ;;
    
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac 