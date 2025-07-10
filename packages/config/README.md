# TODO: merge to the root Readme

# Configuration Package

This package contains Docker configuration and environment setup for the infra-flow project.

## Environment Setup

### ⚠️ CRITICAL: All Environment Variables Required

**Docker containers will NOT start unless ALL environment variables are properly configured in the `.env` file. No fallback values are provided.**

### 1. Create Environment File

Copy the example environment file and customize it:

```bash
# From project root
npm run setup:env

# Or manually
cp packages/config/env.example packages/config/.env
```

### 2. Update ALL Required Values

Edit `packages/config/.env` and replace **ALL** placeholder values:

```env
# PostgreSQL - MUST change this password!
POSTGRES_PASSWORD=your_secure_postgres_password_here

# MinIO - MUST change these passwords!
MINIO_ROOT_PASSWORD=your_secure_minio_password_here
MINIO_SECRET_KEY=your_secure_minio_secret_here

# Database URL - MUST match your POSTGRES_PASSWORD
DATABASE_URL=postgresql://postgres:your_secure_postgres_password_here@postgres:5432/infra_flow
```

### 3. Environment Variables Reference

**ALL of these variables MUST be defined in your `.env` file:**

| Variable               | Description                       | Example                                                               |
| ---------------------- | --------------------------------- | --------------------------------------------------------------------- |
| `NODE_ENV`             | Application environment           | `production`                                                          |
| `POSTGRES_DB`          | PostgreSQL database name          | `infra_flow`                                                          |
| `POSTGRES_USER`        | PostgreSQL username               | `postgres`                                                            |
| `POSTGRES_PASSWORD`    | PostgreSQL password               | `MySecurePassword123!`                                                |
| `DATABASE_URL`         | Full PostgreSQL connection string | `postgresql://postgres:MySecurePassword123!@postgres:5432/infra_flow` |
| `MINIO_ROOT_USER`      | MinIO admin username              | `minioadmin`                                                          |
| `MINIO_ROOT_PASSWORD`  | MinIO admin password              | `MySecureMinioPassword456!`                                           |
| `MINIO_ENDPOINT`       | MinIO server endpoint             | `minio:9000`                                                          |
| `MINIO_ACCESS_KEY`     | MinIO access key                  | `minioadmin`                                                          |
| `MINIO_SECRET_KEY`     | MinIO secret key                  | `MySecureMinioSecret789!`                                             |
| `PORT`                 | API server port                   | `2022`                                                                |
| `NEXT_PUBLIC_API_URL`  | Public API URL for Next.js        | `http://api:2022`                                                     |
| `NEXT_PUBLIC_TRPC_URL` | Public tRPC URL for Next.js       | `http://localhost:2022/trpc`                                          |

### 4. Validation

Always validate your environment setup before starting:

```bash
# This will check for missing or placeholder values
npm run setup:env
```

If validation fails, Docker containers will not start.

## Docker Usage

### Development Mode

```bash
npm run dev
```

### Production Mode

```bash
npm run start
```

### Other Commands

```bash
# View logs
npm run dcr logs

# Stop all services
npm run dcr down

# Clean everything
npm run dcr clean
```

## Database Setup

The Docker containers will automatically:

1. Create the PostgreSQL database if it doesn't exist
2. Run Prisma migrations
3. Generate the Prisma client

For manual database operations:

```bash
# Initialize database
npm run db:init

# Open Prisma Studio
npm run db:studio
```

## Troubleshooting

### Container Won't Start

- **Check environment validation**: Run `npm run setup:env`
- **Verify .env file exists**: `ls -la packages/config/.env`
- **Check Docker logs**: `npm run dcr logs [service-name]`

### Common Issues

1. **Missing .env file**: Run `npm run setup:env` first
2. **Placeholder values**: Replace ALL values with real ones
3. **Wrong DATABASE_URL**: Must match your POSTGRES_PASSWORD
4. **Port conflicts**: Check if ports 2022, 3000, 5432, 9000, 9001 are available

## Security Notes

- **Never commit the `.env` file** - it contains sensitive passwords
- **All variables are required** - no fallbacks provided for security
- **Use strong passwords** in production
- **Change ALL default passwords** before deployment
- **Use environment-specific `.env` files** for different environments

