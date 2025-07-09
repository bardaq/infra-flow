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
    echo "  up          Start all services"
    echo "  down        Stop all services"
    echo "  restart     Restart all services"
    echo "  build       Build all images"
    echo "  rebuild     Rebuild all images without cache"
    echo "  logs        Show logs for all services"
    echo "  logs [svc]  Show logs for specific service"
    echo "  ps          Show running containers"
    echo "  shell [svc] Open shell in service container"
    echo "  clean       Remove all containers, networks, and volumes"
    echo "  dev         Start in development mode"
    echo "  prod        Start in production mode"
    echo "  setup       Setup environment file"
    echo "  help        Show this help message"
    echo ""
    echo "Services: postgres, minio, api, web"
}

# Main commands
case "${1:-help}" in
    "up")
        check_docker
        setup_env
        log_info "Starting all services..."
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
        log_success "All services started successfully!"
        log_info "Web app: http://localhost:3000"
        log_info "API: http://localhost:2022"
        log_info "MinIO Console: http://localhost:9001"
        ;;
    
    "down")
        check_docker
        log_info "Stopping all services..."
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down
        log_success "All services stopped successfully!"
        ;;
    
    "restart")
        check_docker
        log_info "Restarting all services..."
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" restart
        log_success "All services restarted successfully!"
        ;;
    
    "build")
        check_docker
        log_info "Building all images..."
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build
        log_success "All images built successfully!"
        ;;
    
    "rebuild")
        check_docker
        log_info "Rebuilding all images without cache..."
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build --no-cache
        log_success "All images rebuilt successfully!"
        ;;
    
    "logs")
        check_docker
        if [ -n "$2" ]; then
            log_info "Showing logs for service: $2"
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" logs -f "$2"
        else
            log_info "Showing logs for all services..."
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" logs -f
        fi
        ;;
    
    "ps")
        check_docker
        log_info "Showing running containers..."
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps
        ;;
    
    "shell")
        check_docker
        if [ -n "$2" ]; then
            log_info "Opening shell in service: $2"
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" exec "$2" /bin/sh
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
            docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down -v --rmi all
            log_success "Docker environment cleaned successfully!"
        else
            log_info "Operation cancelled."
        fi
        ;;
    
    "dev")
        check_docker
        setup_env
        log_info "Starting in development mode..."
        docker-compose -f "$COMPOSE_FILE" -f "packages/config/docker/docker-compose.override.yml" --env-file "$ENV_FILE" up -d
        log_success "Development environment started successfully!"
        ;;
    
    "prod")
        check_docker
        setup_env
        log_info "Starting in production mode..."
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
        log_success "Production environment started successfully!"
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