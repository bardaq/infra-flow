import { db } from "../../db";
import { S3Service } from "../S3Service";

/**
 * Get all files from database and bucket
 */
export async function getFiles() {
  try {
    // Get files from bucket
    const bucketFiles = await S3Service.listFiles();

    // Get files from database
    const dbFiles = await db.file.findMany({
      orderBy: { createdAt: "desc" },
    });

    return {
      files: dbFiles.map((file: any) => ({
        id: file.id,
        name: file.name,
        originalName: file.originalName,
        url: file.url,
        size: Number(file.size),
        mimeType: file.mimeType,
        createdAt: file.createdAt,
        updatedAt: file.updatedAt,
      })),
      bucketFiles: bucketFiles,
      totalCount: dbFiles.length,
    };
  } catch (error) {
    console.error("Failed to get files:", error);
    throw new Error("Failed to retrieve files");
  }
}

