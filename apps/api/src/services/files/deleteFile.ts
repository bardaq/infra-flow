import type { Prisma } from "@prisma/client";
import { db } from "../../db";
import { S3Service } from "../S3Service";

/**
 * Delete file by ID from both database and bucket
 */
export async function deleteFile(id: string) {
  return await db.$transaction(async (tx: Prisma.TransactionClient) => {
    try {
      // Get file from database first
      const dbFile = await tx.file.findUnique({
        where: { id },
      });

      if (!dbFile) {
        throw new Error("File not found in database");
      }

      // Delete from S3/MinIO bucket
      const s3DeleteSuccess = await S3Service.deleteFile(dbFile.name);

      if (!s3DeleteSuccess) {
        console.warn(
          `File ${dbFile.name} was not found in bucket, proceeding with DB deletion`
        );
      }

      // Delete from database
      await tx.file.delete({
        where: { id },
      });

      return {
        success: true,
        message: "File deleted successfully",
        deletedFile: {
          id: dbFile.id,
          name: dbFile.name,
          originalName: dbFile.originalName,
        },
      };
    } catch (error) {
      console.error("Delete failed:", error);
      throw new Error("Failed to delete file");
    }
  });
}

