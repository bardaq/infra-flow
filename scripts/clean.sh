#!/bin/bash

# Clean script for infra-flow monorepo
# Removes all build artifacts, node_modules, and generated files

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
    if [ ! -f "package.json" ] || [ ! -d "packages" ] || [ ! -d "apps" ]; then
        log_error "This script must be run from the project root directory"
        exit 1
    fi
}

# Count items to be removed
count_items() {
    local count=0
    
    # Count node_modules directories
    count=$((count + $(find . -name "node_modules" -type d 2>/dev/null | wc -l)))
    
    # Count dist directories
    count=$((count + $(find . -name "dist" -type d 2>/dev/null | wc -l)))
    
    # Count .next directories
    count=$((count + $(find . -name ".next" -type d 2>/dev/null | wc -l)))
    
    # Count .turbo directories
    count=$((count + $(find . -name ".turbo" -type d 2>/dev/null | wc -l)))
    
    # Count coverage directories
    count=$((count + $(find . -name "coverage" -type d 2>/dev/null | wc -l)))
    
    # Count tsbuildinfo files
    count=$((count + $(find . -name "*.tsbuildinfo" -type f 2>/dev/null | wc -l)))
    
    # Count generated TypeScript files in src directories
    count=$((count + $(find . -path "*/src/**/*.d.ts" -type f 2>/dev/null | wc -l)))
    count=$((count + $(find . -path "*/src/**/*.d.ts.map" -type f 2>/dev/null | wc -l)))
    count=$((count + $(find . -path "*/src/**/*.js.map" -type f 2>/dev/null | wc -l)))
    
    # Count .js files in TypeScript src directories (generated files)
    count=$((count + $(find packages/ui/src -name "*.js" -type f 2>/dev/null | wc -l)))
    
    # Count Docker resources if Docker is available
    if command -v docker &> /dev/null; then
        local docker_containers=$(docker ps -a --filter "name=infra-flow" --format "{{.Names}}" 2>/dev/null | wc -l)
        local docker_volumes=$(docker volume ls --filter "name=infra-flow" --format "{{.Name}}" 2>/dev/null | wc -l)
        count=$((count + docker_containers + docker_volumes))
    fi
    
    echo $count
}

# Clean node_modules directories
clean_node_modules() {
    log_info "Removing node_modules directories..."
    
    local count=0
    while IFS= read -r -d '' dir; do
        log_info "Removing: $dir"
        rm -rf "$dir"
        count=$((count + 1))
    done < <(find . -name "node_modules" -type d -print0 2>/dev/null)
    
    if [ $count -gt 0 ]; then
        log_success "Removed $count node_modules directories"
    else
        log_info "No node_modules directories found"
    fi
}

# Clean dist directories
clean_dist() {
    log_info "Removing dist directories..."
    
    local count=0
    while IFS= read -r -d '' dir; do
        log_info "Removing: $dir"
        rm -rf "$dir"
        count=$((count + 1))
    done < <(find . -name "dist" -type d -print0 2>/dev/null)
    
    if [ $count -gt 0 ]; then
        log_success "Removed $count dist directories"
    else
        log_info "No dist directories found"
    fi
}

# Clean Next.js build directories
clean_nextjs() {
    log_info "Removing .next directories..."
    
    local count=0
    while IFS= read -r -d '' dir; do
        log_info "Removing: $dir"
        rm -rf "$dir"
        count=$((count + 1))
    done < <(find . -name ".next" -type d -print0 2>/dev/null)
    
    if [ $count -gt 0 ]; then
        log_success "Removed $count .next directories"
    else
        log_info "No .next directories found"
    fi
}

# Clean Turbo cache directories
clean_turbo() {
    log_info "Removing .turbo cache directories..."
    
    local count=0
    while IFS= read -r -d '' dir; do
        log_info "Removing: $dir"
        rm -rf "$dir"
        count=$((count + 1))
    done < <(find . -name ".turbo" -type d -print0 2>/dev/null)
    
    if [ $count -gt 0 ]; then
        log_success "Removed $count .turbo directories"
    else
        log_info "No .turbo directories found"
    fi
}

# Clean coverage directories
clean_coverage() {
    log_info "Removing coverage directories..."
    
    local count=0
    while IFS= read -r -d '' dir; do
        log_info "Removing: $dir"
        rm -rf "$dir"
        count=$((count + 1))
    done < <(find . -name "coverage" -type d -print0 2>/dev/null)
    
    if [ $count -gt 0 ]; then
        log_success "Removed $count coverage directories"
    else
        log_info "No coverage directories found"
    fi
}

# Clean TypeScript build info files
clean_tsbuildinfo() {
    log_info "Removing *.tsbuildinfo files..."
    
    local count=0
    while IFS= read -r -d '' file; do
        log_info "Removing: $file"
        rm -f "$file"
        count=$((count + 1))
    done < <(find . -name "*.tsbuildinfo" -type f -print0 2>/dev/null)
    
    if [ $count -gt 0 ]; then
        log_success "Removed $count .tsbuildinfo files"
    else
        log_info "No .tsbuildinfo files found"
    fi
}

# Clean generated TypeScript files
clean_generated_ts() {
    log_info "Removing generated TypeScript files..."
    
    local count=0
    
    # Remove .d.ts files in src directories (generated)
    while IFS= read -r -d '' file; do
        log_info "Removing: $file"
        rm -f "$file"
        count=$((count + 1))
    done < <(find . -path "*/src/**/*.d.ts" -type f -print0 2>/dev/null)
    
    # Remove .d.ts.map files
    while IFS= read -r -d '' file; do
        log_info "Removing: $file"
        rm -f "$file"
        count=$((count + 1))
    done < <(find . -path "*/src/**/*.d.ts.map" -type f -print0 2>/dev/null)
    
    # Remove .js.map files in src directories
    while IFS= read -r -d '' file; do
        log_info "Removing: $file"
        rm -f "$file"
        count=$((count + 1))
    done < <(find . -path "*/src/**/*.js.map" -type f -print0 2>/dev/null)
    
    # Remove generated .js files in TypeScript packages (be more specific)
    while IFS= read -r -d '' file; do
        # Check if corresponding .tsx or .ts file exists
        local basename=$(basename "$file" .js)
        local dirname=$(dirname "$file")
        if [ -f "$dirname/$basename.tsx" ] || [ -f "$dirname/$basename.ts" ]; then
            log_info "Removing generated: $file"
            rm -f "$file"
            count=$((count + 1))
        fi
    done < <(find packages/ui/src -name "*.js" -type f -print0 2>/dev/null)
    
    if [ $count -gt 0 ]; then
        log_success "Removed $count generated TypeScript files"
    else
        log_info "No generated TypeScript files found"
    fi
}

# Clean log files
clean_logs() {
    log_info "Removing log files..."
    
    local count=0
    
    # Remove common log files
    for pattern in "*.log" "npm-debug.log*" "yarn-debug.log*" "yarn-error.log*"; do
        while IFS= read -r -d '' file; do
            log_info "Removing: $file"
            rm -f "$file"
            count=$((count + 1))
        done < <(find . -name "$pattern" -type f -print0 2>/dev/null)
    done
    
    # Clean logs directory
    if [ -d "packages/config/logs" ]; then
        log_info "Cleaning logs directory..."
        rm -rf packages/config/logs/*
        count=$((count + 1))
    fi
    
    if [ $count -gt 0 ]; then
        log_success "Removed $count log files and directories"
    else
        log_info "No log files found"
    fi
}

# Clean Docker containers and volumes
clean_docker() {
    log_info "Cleaning Docker containers and volumes..."
    
    local count=0
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        log_warn "Docker not found, skipping Docker cleanup"
        return
    fi
    
    # Stop and remove infra-flow containers
    local containers=$(docker ps -a --filter "name=infra-flow" --format "{{.Names}}" 2>/dev/null)
    if [ -n "$containers" ]; then
        log_info "Stopping infra-flow containers..."
        echo "$containers" | while read -r container; do
            log_info "Stopping container: $container"
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
            count=$((count + 1))
        done
    fi
    
    # Remove infra-flow volumes
    local volumes=$(docker volume ls --filter "name=infra-flow" --format "{{.Name}}" 2>/dev/null)
    if [ -n "$volumes" ]; then
        log_info "Removing infra-flow volumes..."
        echo "$volumes" | while read -r volume; do
            log_info "Removing volume: $volume"
            docker volume rm "$volume" 2>/dev/null || true
            count=$((count + 1))
        done
    fi
    
    # Remove infra-flow network if it exists
    if docker network ls --filter "name=infra-flow-network" --format "{{.Name}}" | grep -q "infra-flow-network"; then
        log_info "Removing infra-flow network..."
        docker network rm infra-flow-network 2>/dev/null || true
        count=$((count + 1))
    fi
    
    # Clean up dangling images
    local dangling=$(docker images -f "dangling=true" -q 2>/dev/null)
    if [ -n "$dangling" ]; then
        log_info "Removing dangling Docker images..."
        docker rmi $dangling 2>/dev/null || true
        count=$((count + 1))
    fi
    
    if [ $count -gt 0 ]; then
        log_success "Cleaned $count Docker resources"
    else
        log_info "No Docker resources found to clean"
    fi
}

# Clean Docker Compose services
clean_docker_compose() {
    log_info "Cleaning Docker Compose services..."
    
    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null; then
        log_warn "docker-compose not found, skipping Docker Compose cleanup"
        return
    fi
    
    # Navigate to docker config directory
    local docker_dir="packages/config/docker"
    if [ -d "$docker_dir" ]; then
        log_info "Stopping Docker Compose services..."
        cd "$docker_dir"
        
        # Stop and remove services
        docker-compose -f docker-compose.yml -f docker-compose.override.yml down --volumes --remove-orphans 2>/dev/null || true
        
        # Remove specific service containers if they exist
        for service in "infra-flow-postgres" "infra-flow-minio" "infra-flow-api" "infra-flow-web" "infra-flow-prisma-studio"; do
            if docker ps -a --filter "name=$service" --format "{{.Names}}" | grep -q "$service"; then
                log_info "Removing container: $service"
                docker rm -f "$service" 2>/dev/null || true
            fi
        done
        
        # Return to project root
        cd - > /dev/null
        log_success "Docker Compose services cleaned"
    else
        log_warn "Docker directory not found at $docker_dir"
    fi
}

# Show what will be cleaned
show_preview() {
    echo "🧹 infra-flow Clean Script"
    echo ""
    echo "This script will remove the following types of files and directories:"
    echo ""
    echo "  📁 Directories:"
    echo "    • node_modules/"
    echo "    • dist/"
    echo "    • .next/"
    echo "    • .turbo/"
    echo "    • coverage/"
    echo "    • packages/config/logs/"
    echo ""
    echo "  📄 Files:"
    echo "    • *.tsbuildinfo"
    echo "    • Generated .d.ts, .d.ts.map, .js.map files in src/"
    echo "    • Generated .js files in TypeScript packages"
    echo "    • Log files (*.log, npm-debug.log*, etc.)"
    echo ""
    echo "  🐳 Docker Resources:"
    echo "    • infra-flow containers (postgres, minio, api, web, prisma-studio)"
    echo "    • infra-flow volumes"
    echo "    • infra-flow network"
    echo "    • Dangling Docker images"
    echo ""
    
    local total_items=$(count_items)
    if [ $total_items -gt 0 ]; then
        log_warn "Found $total_items items to clean"
    else
        log_info "No items found to clean"
        exit 0
    fi
}

# Main cleanup function
main() {
    check_root_directory
    show_preview
    
    echo ""
    read -p "Do you want to proceed with cleaning? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleanup cancelled."
        exit 0
    fi
    
    echo ""
    log_info "Starting cleanup..."
    echo ""
    
    clean_docker_compose
    clean_docker
    clean_node_modules
    clean_dist
    clean_nextjs
    clean_turbo
    clean_coverage
    clean_tsbuildinfo
    clean_generated_ts
    clean_logs
    
    echo ""
    log_success "🎉 Cleanup completed successfully!"
    log_info "You may want to run 'npm install' to reinstall dependencies"
}

# Show help
show_help() {
    echo "Clean script for infra-flow monorepo"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help, -h      Show this help message"
    echo "  --preview, -p   Show what will be cleaned without removing"
    echo "  --force, -f     Clean without confirmation prompt"
    echo ""
    echo "This script removes:"
    echo "  • node_modules directories"
    echo "  • dist directories"
    echo "  • .next directories"
    echo "  • .turbo cache directories"
    echo "  • coverage directories"
    echo "  • TypeScript build info files"
    echo "  • Generated TypeScript files"
    echo "  • Log files"
    echo "  • Docker containers and volumes (infra-flow services)"
    echo "  • Docker networks (infra-flow-network)"
    echo "  • Dangling Docker images"
}

# Parse command line arguments
case "${1:-}" in
    "--help"|"-h")
        show_help
        exit 0
        ;;
    "--preview"|"-p")
        check_root_directory
        show_preview
        exit 0
        ;;
    "--force"|"-f")
        check_root_directory
        log_info "Force cleaning (no confirmation)..."
        echo ""
        clean_docker_compose
        clean_docker
        clean_node_modules
        clean_dist
        clean_nextjs
        clean_turbo
        clean_coverage
        clean_tsbuildinfo
        clean_generated_ts
        clean_logs
        echo ""
        log_success "🎉 Cleanup completed successfully!"
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