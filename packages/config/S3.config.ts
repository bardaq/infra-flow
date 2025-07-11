const { MINIO_ENDPOINT, MINIO_ACCESS_KEY, MINIO_SECRET_KEY } = process.env;

console.log({
  MINIO_ENDPOINT,
  MINIO_ACCESS_KEY,
  MINIO_SECRET_KEY,
});

if (!MINIO_ENDPOINT || !MINIO_ACCESS_KEY || !MINIO_SECRET_KEY) {
  throw new Error("Missing S3 configuration");
}

const S3_CONFIG = {
  endpoint: MINIO_ENDPOINT,
  accessKeyId: MINIO_ACCESS_KEY,
  secretAccessKey: MINIO_SECRET_KEY,
  region: "us-east-1",
  forcePathStyle: true,
};

export type S3Config = typeof S3_CONFIG;

export default S3_CONFIG;

