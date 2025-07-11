import {
  type PutObjectCommandInput,
  type ListObjectsV2CommandInput,
  S3Client,
  CreateBucketCommand,
  PutObjectCommand,
  DeleteObjectCommand,
  ListObjectsV2Command,
  HeadBucketCommand,
  DeleteBucketCommand,
} from "@aws-sdk/client-s3";
import { S3_CONFIG } from "@workspace/config/S3.config";

export class S3ServiceSingleton {
  private s3Client: S3Client;
  private defaultBucket: string;

  constructor(
    config: {
      endpoint: string;
      accessKeyId: string;
      secretAccessKey: string;
      region?: string;
      forcePathStyle?: boolean;
    },
    defaultBucket: string = "uploads"
  ) {
    this.s3Client = new S3Client({
      endpoint: config.endpoint,
      region: config.region || "us-east-1",
      credentials: {
        accessKeyId: config.accessKeyId,
        secretAccessKey: config.secretAccessKey,
      },
      forcePathStyle: config.forcePathStyle ?? true, // Required for MinIO
    });
    this.defaultBucket = defaultBucket;
  }

  /**
   * Check if bucket exists, create if it doesn't
   */
  async ensureBucketExists(
    bucketName: string = this.defaultBucket
  ): Promise<void> {
    try {
      await this.s3Client.send(new HeadBucketCommand({ Bucket: bucketName }));
    } catch (error: any) {
      if (
        error.name === "NotFound" ||
        error.$metadata?.httpStatusCode === 404
      ) {
        await this.s3Client.send(
          new CreateBucketCommand({ Bucket: bucketName })
        );
        console.log(`✅ Created bucket: ${bucketName}`);
      } else {
        throw error;
      }
    }
  }

  /**
   * Upload a file to MinIO
   */
  async uploadFile(
    file: {
      originalName: string;
      mimeType: string;
      size: number;
      buffer: Buffer;
    },
    bucketName: string = this.defaultBucket,
    customKey?: string
  ) {
    // Ensure bucket exists
    await this.ensureBucketExists(bucketName);

    // Generate unique key if not provided
    const key = customKey || `${Date.now()}-${file.originalName}`;

    const uploadParams: PutObjectCommandInput = {
      Bucket: bucketName,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimeType,
      ContentLength: file.size,
      Metadata: {
        originalName: file.originalName,
        uploadedAt: new Date().toISOString(),
      },
    };

    await this.s3Client.send(new PutObjectCommand(uploadParams));

    // Generate file URL
    const url = `${this.s3Client.config.endpoint}/${bucketName}/${key}`;

    return {
      key,
      originalName: file.originalName,
      url,
      size: file.size,
      mimeType: file.mimeType,
    };
  }

  /**
   * List all files in bucket
   */
  async listFiles(bucketName: string = this.defaultBucket, prefix?: string) {
    await this.ensureBucketExists(bucketName);

    const params: ListObjectsV2CommandInput = {
      Bucket: bucketName,
      Prefix: prefix,
    };

    const response = await this.s3Client.send(new ListObjectsV2Command(params));

    if (!response.Contents) {
      return [];
    }

    return response.Contents.map((object) => ({
      key: object.Key!,
      originalName: object.Key!.split("-").slice(1).join("-") || object.Key!,
      url: `${this.s3Client.config.endpoint}/${bucketName}/${object.Key}`,
      size: object.Size || 0,
      mimeType: "", // Not available in list response
      lastModified: object.LastModified,
    }));
  }

  /**
   * Delete a file
   */
  async deleteFile(
    key: string,
    bucketName: string = this.defaultBucket
  ): Promise<boolean> {
    try {
      await this.s3Client.send(
        new DeleteObjectCommand({
          Bucket: bucketName,
          Key: key,
        })
      );
      return true;
    } catch (error: any) {
      if (error.name === "NoSuchKey") return false; // File didn't exist
      throw error;
    }
  }

  /**
   * Delete entire bucket (use with caution!)
   */
  async deleteBucket(bucketName: string): Promise<void> {
    // First, delete all objects in the bucket
    const objects = await this.listFiles(bucketName);

    for (const object of objects) {
      await this.deleteFile(object.key, bucketName);
    }

    // Then delete the bucket
    await this.s3Client.send(new DeleteBucketCommand({ Bucket: bucketName }));
  }
}

export const S3Service = new S3ServiceSingleton(S3_CONFIG);

