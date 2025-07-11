"use client";

import { useState, useRef } from "react";
import { Button } from "@workspace/ui/components/button";
import { API } from "@/lib/trpc/API.client";
import { PngGenerator } from "./PngGenerator";

interface FileData {
  id: string;
  name: string;
  originalName: string;
  mimeType: string;
  size: number;
  createdAt: string;
  updatedAt: string;
}

export function FileTestForm() {
  const [fileName, setFileName] = useState("");
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // tRPC hooks
  const filesQuery = API.files.getFiles.useQuery();
  const uploadMutation = API.files.uploadFile.useMutation({
    onSuccess: () => {
      // Reset form
      setFileName("");
      setSelectedFile(null);
      if (fileInputRef.current) {
        fileInputRef.current.value = "";
      }
      // Refetch files list
      filesQuery.refetch();
    },
  });
  const deleteMutation = API.files.deleteFile.useMutation({
    onSuccess: () => {
      // Refetch files list
      filesQuery.refetch();
    },
  });

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      setSelectedFile(file);
      // Auto-fill the name with the file name if empty
      if (!fileName) {
        setFileName(file.name);
      }
    }
  };

  const handleGeneratedFile = (file: File) => {
    setSelectedFile(file);
    // Auto-fill the name with the file name if empty
    if (!fileName) {
      setFileName(file.name);
    }

    // Create a new FileList with the generated file and assign it to the input
    const dataTransfer = new DataTransfer();
    dataTransfer.items.add(file);

    if (fileInputRef.current) {
      fileInputRef.current.files = dataTransfer.files;
    }
  };

  const handleUpload = async () => {
    if (!selectedFile || !fileName.trim()) {
      alert("Please select a file and enter a name");
      return;
    }

    try {
      const arrayBuffer = await selectedFile.arrayBuffer();

      await uploadMutation.mutateAsync({
        name: fileName,
        file: {
          name: selectedFile.name,
          type: selectedFile.type,
          size: selectedFile.size,
          arrayBuffer,
        },
      });
    } catch (error) {
      console.error("Upload failed:", error);
      alert("Upload failed. Check console for details.");
    }
  };

  const handleDelete = async (fileId: string) => {
    if (!confirm("Are you sure you want to delete this file?")) {
      return;
    }

    try {
      await deleteMutation.mutateAsync({ id: fileId });
    } catch (error) {
      console.error("Delete failed:", error);
      alert("Delete failed. Check console for details.");
    }
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  };

  return (
    <div className="border p-6 rounded-lg max-w-2xl mx-auto">
      <h3 className="font-semibold mb-4 text-lg">File Upload Test</h3>

      {/* Upload Form */}
      <div className="space-y-4 mb-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            File Name
          </label>
          <input
            type="text"
            placeholder="Enter file name"
            value={fileName}
            onChange={(e) => setFileName(e.target.value)}
            className="w-full border rounded px-3 py-2 text-sm"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Select File
          </label>
          <input
            ref={fileInputRef}
            type="file"
            onChange={handleFileSelect}
            className="w-full border rounded px-3 py-2 text-sm"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Or Generate Test File
          </label>
          <PngGenerator onFileGenerated={handleGeneratedFile} />
        </div>

        {selectedFile && (
          <div className="text-sm text-gray-600 bg-gray-50 p-2 rounded">
            <p>
              <strong>Selected:</strong> {selectedFile.name}
            </p>
            <p>
              <strong>Type:</strong> {selectedFile.type}
            </p>
            <p>
              <strong>Size:</strong> {formatFileSize(selectedFile.size)}
            </p>
          </div>
        )}

        <Button
          onClick={handleUpload}
          disabled={
            !selectedFile || !fileName.trim() || uploadMutation.isPending
          }
          className="w-full"
        >
          {uploadMutation.isPending ? "Uploading..." : "Upload File"}
        </Button>

        {uploadMutation.error && (
          <div className="text-red-600 text-sm bg-red-50 p-2 rounded">
            Error: {uploadMutation.error.message}
          </div>
        )}
      </div>

      {/* Files List */}
      <div className="space-y-4">
        <div className="flex justify-between items-center">
          <h4 className="font-medium">Uploaded Files</h4>
          <Button
            onClick={() => filesQuery.refetch()}
            disabled={filesQuery.isLoading}
            size="sm"
            variant="outline"
          >
            {filesQuery.isLoading ? "Loading..." : "Refresh"}
          </Button>
        </div>

        {filesQuery.error && (
          <div className="text-red-600 text-sm bg-red-50 p-2 rounded">
            Error loading files: {filesQuery.error.message}
          </div>
        )}

        <div className="space-y-2">
          {filesQuery.data?.map((file: FileData) => (
            <div
              key={file.id}
              className="flex items-center justify-between p-3 bg-gray-50 rounded border"
            >
              <div className="flex-1">
                <div className="font-medium text-sm">{file.name}</div>
                <div className="text-xs text-gray-600">
                  {file.originalName} • {file.mimeType} •{" "}
                  {formatFileSize(file.size)}
                </div>
                <div className="text-xs text-gray-500">
                  Created: {new Date(file.createdAt).toLocaleString()}
                </div>
              </div>
              <Button
                onClick={() => handleDelete(file.id)}
                disabled={deleteMutation.isPending}
                size="sm"
                variant="outline"
                className="ml-2 text-red-600 hover:text-red-700"
              >
                {deleteMutation.isPending ? "Deleting..." : "Delete"}
              </Button>
            </div>
          ))}

          {filesQuery.data?.length === 0 && (
            <div className="text-center text-gray-500 py-4">
              No files uploaded yet
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

