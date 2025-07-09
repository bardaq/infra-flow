#!/bin/bash

# Setup script for infra-flow Docker environment
# This script initializes the entire Docker setup

set -e

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

# Check if running from project root
check_root_directory() {
    if [ ! -f "package.json" ] || [ ! -d "packages/config" ]; then
        log_error "This script must be run from the project root directory"
        exit 1
    fi
}

# Check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi

    log_success "Docker is installed and running"
}

# Check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi

    log_success "Docker Compose is available"
}

# Setup environment file
setup_environment() {
    local env_file="packages/config/.env"
    local env_example="packages/config/env.example"

    if [ -f "$env_file" ]; then
        log_warn "Environment file already exists: $env_file"
        read -p "Do you want to overwrite it? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing environment file"
            return
        fi
    fi

    log_info "Creating environment file from template..."
    cp "$env_example" "$env_file"
    
    log_success "Environment file created: $env_file"
    log_warn "Please review and update the environment variables in $env_file"
}

# Install dependencies
install_dependencies() {
    log_info "Installing project dependencies..."
    
    if command -v npm &> /dev/null; then
        npm install
        log_success "Dependencies installed successfully"
    else
        log_error "npm is not installed. Please install Node.js and npm first."
        exit 1
    fi
}

# Generate Prisma client
generate_prisma() {
    log_info "Generating Prisma client..."
    
    if [ -f "apps/api/src/db/schema.prisma" ]; then
        cd apps/api
        npm run db:generate
        cd ../..
        log_success "Prisma client generated successfully"
    else
        log_warn "Prisma schema not found, skipping Prisma generation"
    fi
}

# Build Docker images
build_docker_images() {
    log_info "Building Docker images..."
    
    ./scripts/docker-compose.sh build
    log_success "Docker images built successfully"
}

# Start services
start_services() {
    log_info "Starting all services..."
    
    ./scripts/docker-compose.sh up
    
    log_success "All services started successfully!"
    echo ""
    echo "🎉 Setup complete! Your services are now running:"
    echo ""
    echo "  📱 Web App:        http://localhost:3000"
    echo "  🔌 API:            http://localhost:2022"
    echo "  🗄️  MinIO Console:  http://localhost:9001 (minioadmin/minioadmin123)"
    echo "  🐘 PostgreSQL:     localhost:5432"
    echo ""
    echo "📖 For more information, see packages/config/DOCKER_SETUP.md"
}

# Main setup function
main() {
    echo "🚀 Setting up infra-flow Docker environment..."
    echo ""
    
    check_root_directory
    check_docker
    check_docker_compose
    setup_environment
    install_dependencies
    generate_prisma
    build_docker_images
    
    echo ""
    read -p "Do you want to start the services now? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        start_services
    else
        log_info "Setup complete! You can start services later with:"
        echo "  ./packages/config/docker/docker-compose.sh up"
    fi
}

# Show help
show_help() {
    echo "Setup script for infra-flow Docker environment"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --no-start      Setup without starting services"
    echo ""
    echo "This script will:"
    echo "  1. Check Docker installation"
    echo "  2. Setup environment variables"
    echo "  3. Install dependencies"
    echo "  4. Generate Prisma client"
    echo "  5. Build Docker images"
    echo "  6. Start services (optional)"
}

# Parse command line arguments
case "${1:-}" in
    "--help"|"-h")
        show_help
        exit 0
        ;;
    "--no-start")
        echo "🚀 Setting up infra-flow Docker environment (without starting services)..."
        echo ""
        check_root_directory
        check_docker
        check_docker_compose
        setup_environment
        install_dependencies
        generate_prisma
        build_docker_images
        log_success "Setup complete! Start services with: ./scripts/docker-compose.sh up"
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac 