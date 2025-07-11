const { MINIO_ENDPOINT, MINIO_ACCESS_KEY, MINIO_SECRET_KEY } = process.env;

if (!MINIO_ENDPOINT || !MINIO_ACCESS_KEY || !MINIO_SECRET_KEY) {
  throw new Error("Missing S3 configuration");
}

export const S3_CONFIG = {
  endpoint: MINIO_ENDPOINT,
  accessKeyId: MINIO_ACCESS_KEY,
  secretAccessKey: MINIO_SECRET_KEY,
  region: "us-east-1",
  forcePathStyle: true,
};

