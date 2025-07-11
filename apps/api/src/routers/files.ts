import { z } from "zod";
import { publicProcedure, router } from "../trpc";
import { uploadFile } from "../servies/files/uploadFile";
import { deleteFile } from "src/servies/files/deleteFile";
import { getFiles } from "src/servies/files/getFiles";

export const filesRouter = router({
  /**
   * Upload file to bucket and create DB record in transaction
   */
  uploadFile: publicProcedure
    .input(
      z.object({
        name: z.string().min(1, "Name is required"),
        file: z.object({
          name: z.string(),
          type: z.string(),
          size: z.number(),
          arrayBuffer: z.instanceof(ArrayBuffer),
        }),
      })
    )
    .mutation(async ({ input }) => {
      const { name, file } = input;

      // Convert ArrayBuffer to Buffer
      const buffer = Buffer.from(file.arrayBuffer);

      // Prepare file data for service
      const fileData = {
        originalName: file.name,
        mimeType: file.type,
        size: file.size,
        buffer,
      };

      // Use service to handle upload
      return await uploadFile(fileData, name);
    }),

  /**
   * Get all files from database and bucket
   */
  getFiles: publicProcedure.query(async () => {
    return await getFiles();
  }),

  /**
   * Delete file by ID from both database and bucket
   */
  deleteFile: publicProcedure
    .input(z.object({ id: z.string().uuid("Invalid file ID") }))
    .mutation(async ({ input }) => {
      const { id } = input;
      return await deleteFile(id);
    }),
});

