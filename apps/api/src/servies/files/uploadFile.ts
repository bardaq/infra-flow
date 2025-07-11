import type { Prisma } from "@prisma/client";
import { db } from "../../db";
import { S3Service } from "../S3Service";

export interface FileUploadData {
  originalName: string;
  mimeType: string;
  size: number;
  buffer: Buffer;
}

export async function uploadFile(fileData: FileUploadData, customKey?: string) {
  return await db.$transaction(async (tx: Prisma.TransactionClient) => {
    try {
      // Upload to S3/MinIO
      const s3Result = await S3Service.uploadFile(
        fileData,
        undefined,
        customKey
      );

      // Create database record
      const dbFile = await tx.file.create({
        data: {
          name: s3Result.key,
          originalName: s3Result.originalName,
          url: s3Result.url,
          size: BigInt(s3Result.size),
          mimeType: s3Result.mimeType,
        },
      });

      return {
        id: dbFile.id,
        name: dbFile.name,
        originalName: dbFile.originalName,
        url: dbFile.url,
        size: Number(dbFile.size),
        mimeType: dbFile.mimeType,
        createdAt: dbFile.createdAt,
        updatedAt: dbFile.updatedAt,
      };
    } catch (error) {
      // Transaction will automatically roll back
      console.error("Upload failed:", error);
      throw new Error("Failed to upload file");
    }
  });
}

