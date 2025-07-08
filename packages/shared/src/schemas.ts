// Common types and schemas used across the application
import { z } from 'zod';

// File schema
export const FileSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  originalName: z.string(),
  url: z.string().url(),
  size: z.number().int().positive(),
  mimeType: z.string(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

// Upload file schema
export const UploadFileSchema = z.object({
  name: z.string().min(1),
  file: z.any(), // File object from FormData
});


// Delete file schema
export const DeleteFileSchema = z.object({
  id: z.string().uuid(),
});
