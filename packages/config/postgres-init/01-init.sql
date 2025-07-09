-- Initialize PostgreSQL database for infra-flow
-- This script runs automatically when the PostgreSQL container starts

-- Create necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create database if it doesn't exist (this is handled by POSTGRES_DB env var)
-- But we can add additional setup here

-- Set timezone
SET timezone = 'UTC';

-- Create a healthcheck function
CREATE OR REPLACE FUNCTION healthcheck() RETURNS TEXT AS $$
BEGIN
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION healthcheck() TO PUBLIC; 