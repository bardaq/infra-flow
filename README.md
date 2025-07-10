# Docker Compose Setup for infra-flow

## 🏗️ Architecture

The Docker setup includes four main services:

1. **PostgreSQL Database** (`postgres`) - Database server with persistent storage
2. **MinIO Object Storage** (`minio`) - File storage service with web console
3. **API Server** (`api`) - Fastify-based backend with tRPC
4. **Web Application** (`web`) - Next.js frontend with UI components

## 📁 File Structure

```
packages/config/
├── docker-compose.yml           # Main Docker Compose configuration
├── docker-compose.override.yml  # Development overrides
├── docker-compose.sh           # Management script
├── Dockerfile.api              # API service Dockerfile
├── Dockerfile.web              # Web app Dockerfile
├── .dockerignore               # Docker ignore patterns
├── env.example                 # Environment variables template
├── postgres-init/              # Database initialization scripts
│   └── 01-init.sql
└── DOCKER_SETUP.md            # This file
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available for Docker
- Ports 3000, 2022, 5432, 9000, 9001 available

### 1. Setup Environment

```bash
# Copy environment template
cp packages/config/env.example packages/config/.env

# Edit the environment file with your preferred settings
nano packages/config/.env
```

### 2. Start Services

```bash
# Using the management script (recommended)
./packages/config/docker/docker-compose.sh up

# Or using docker-compose directly
docker-compose -f packages/config/docker/docker-compose.yml up -d
```

### 3. Access Services

- **Web App**: http://localhost:3000
- **API**: http://localhost:2022
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin123)
- **PostgreSQL**: localhost:5432

## 🛠️ Management Script

The `docker-compose.sh` script provides convenient commands:

```bash
# Start all services
./packages/config/docker/docker-compose.sh up

# Stop all services
./packages/config/docker/docker-compose.sh down

# Start in development mode (with hot reload)
./packages/config/docker/docker-compose.sh dev

# View logs
./packages/config/docker/docker-compose.sh logs
./packages/config/docker/docker-compose.sh logs api

# Rebuild images
./packages/config/docker/docker-compose.sh build

# Clean up everything
./packages/config/docker/docker-compose.sh clean

# Show help
./packages/config/docker/docker-compose.sh help
```

## 🔧 Development Mode

For development, use the override configuration:

```bash
./packages/config/docker/docker-compose.sh dev
```

This provides:

- Hot reloading for both API and web services
- Volume mounts for source code
- Development environment variables
- Enhanced logging

## 🗄️ Database Setup

The PostgreSQL service automatically:

- Creates the database specified in `POSTGRES_DB`
- Runs initialization scripts from `postgres-init/`
- Sets up necessary extensions (uuid-ossp, pgcrypto)

### Running Migrations

```bash
# Access the API container
./packages/config/docker/docker-compose.sh shell api

# Run Prisma migrations
npm run db:migrate

# Or generate the client
npm run db:generate
```

## 📦 MinIO File Storage

MinIO provides S3-compatible object storage:

- **API Endpoint**: http://localhost:9000
- **Web Console**: http://localhost:9001
- **Default Credentials**: minioadmin/minioadmin123

### Creating Buckets

Access the MinIO console at http://localhost:9001 and create buckets as needed.

## 🌐 Environment Variables

Key environment variables (see `env.example`):

### Database

- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database user
- `POSTGRES_PASSWORD`: Database password
- `DATABASE_URL`: Full database connection string

### MinIO

- `MINIO_ROOT_USER`: MinIO admin username
- `MINIO_ROOT_PASSWORD`: MinIO admin password

### API

- `NODE_ENV`: Environment mode (development/production)
- `PORT`: API server port

### Web

- `NEXT_PUBLIC_API_URL`: API URL for client-side requests
- `NEXT_PUBLIC_TRPC_URL`: tRPC endpoint URL

## 🔍 Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 3000, 2022, 5432, 9000, 9001 are available
2. **Memory issues**: Increase Docker memory limit to at least 4GB
3. **Build failures**: Run `./packages/config/docker/docker-compose.sh clean` and rebuild

### Logs

```bash
# View all logs
./packages/config/docker/docker-compose.sh logs

# View specific service logs
./packages/config/docker/docker-compose.sh logs postgres
./packages/config/docker/docker-compose.sh logs api
./packages/config/docker/docker-compose.sh logs web
./packages/config/docker/docker-compose.sh logs minio
```

### Health Checks

All services include health checks. Check service status:

```bash
docker-compose -f packages/config/docker/docker-compose.yml ps
```

## 🔒 Security Notes

- Change default passwords in production
- Use environment-specific configurations
- Enable TLS for production deployments
- Regularly update Docker images

## 🚀 Production Deployment

For production:

1. Update environment variables with secure values
2. Use production-grade PostgreSQL and MinIO configurations
3. Enable SSL/TLS
4. Set up proper backup strategies
5. Configure monitoring and logging

```bash
# Start in production mode
./packages/config/docker/docker-compose.sh prod
```

## 📊 Monitoring

Access service metrics:

- API health: http://localhost:2022/health
- MinIO metrics: Available through MinIO console
- PostgreSQL: Use standard PostgreSQL monitoring tools

## 🔄 Updates

To update the Docker setup:

```bash
# Pull latest images
docker-compose -f packages/config/docker/docker-compose.yml pull

# Rebuild custom images
./packages/config/docker/docker-compose.sh rebuild
```

