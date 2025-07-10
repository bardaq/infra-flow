#!/bin/bash

# Database initialization script for infra-flow
# This script creates the initial migration and sets up the database

set -e

echo "🚀 Initializing infra-flow database..."

# Navigate to the API directory
cd apps/api

# Check if migrations directory exists and is empty
if [ ! -d "src/db/migrations" ] || [ -z "$(ls -A src/db/migrations)" ]; then
    echo "📦 Creating initial migration..."
    npx prisma migrate dev --name init --schema=src/db/schema.prisma
else
    echo "✅ Migrations already exist, applying them..."
    npx prisma migrate deploy --schema=src/db/schema.prisma
fi

# Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate --schema=src/db/schema.prisma

echo "✅ Database initialization complete!"
echo ""
echo "🎯 Next steps:"
echo "  - For development: npm run dev
echo "  - To view database: npm run db:studio (in apps/api)" 