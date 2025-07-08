import type { DeleteFileSchema, FileSchema, UploadFileSchema } from "./schemas";
import { z } from "zod";

export type File =  z.infer<typeof FileSchema>;

export type UploadFileInput = z.infer<typeof UploadFileSchema>;

export type DeleteFileInput = z.infer<typeof DeleteFileSchema>;

// API Response types
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
}

// Kafka Event types
export interface FileUploadedEvent {
  fileId: string;
  fileName: string;
  fileSize: number;
  uploadedAt: string;
  userId?: string;
} 