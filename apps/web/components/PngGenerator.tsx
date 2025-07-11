"use client";

import { useState } from "react";
import { Button } from "@workspace/ui/components/button";

interface PngGeneratorProps {
  onFileGenerated: (file: File) => void;
}

export function PngGenerator({ onFileGenerated }: PngGeneratorProps) {
  const [isGenerating, setIsGenerating] = useState(false);
  const [lastGeneratedName, setLastGeneratedName] = useState<string | null>(
    null
  );

  const generateRandomPng = async (): Promise<void> => {
    setIsGenerating(true);

    try {
      // Create a canvas element
      const canvas = document.createElement("canvas");
      canvas.width = 8;
      canvas.height = 8;
      const ctx = canvas.getContext("2d");

      if (!ctx) {
        throw new Error("Could not get canvas context");
      }

      // Generate random pixels
      const imageData = ctx.createImageData(8, 8);
      const data = imageData.data;

      // Fill each pixel with random RGB values
      for (let i = 0; i < data.length; i += 4) {
        data[i] = Math.floor(Math.random() * 256); // Red
        data[i + 1] = Math.floor(Math.random() * 256); // Green
        data[i + 2] = Math.floor(Math.random() * 256); // Blue
        data[i + 3] = 255; // Alpha (fully opaque)
      }

      // Put the image data on the canvas
      ctx.putImageData(imageData, 0, 0);

      // Convert canvas to blob
      const blob = await new Promise<Blob>((resolve, reject) => {
        canvas.toBlob((blob) => {
          if (blob) {
            resolve(blob);
          } else {
            reject(new Error("Failed to create blob"));
          }
        }, "image/png");
      });

      // Create a file from the blob
      const timestamp = new Date().getTime();
      const fileName = `random-8x8-${timestamp}.png`;
      const file = new File([blob], fileName, { type: "image/png" });

      // Pass the file to the parent component
      onFileGenerated(file);
      setLastGeneratedName(fileName);
    } catch (error) {
      console.error("Error generating PNG:", error);
      alert("Failed to generate PNG. Check console for details.");
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="space-y-2">
      <Button
        onClick={generateRandomPng}
        disabled={isGenerating}
        size="sm"
        variant="outline"
        className="w-full"
      >
        {isGenerating ? "Generating..." : "Generate Random 8x8 PNG"}
      </Button>

      {lastGeneratedName && (
        <div className="text-xs text-gray-600 bg-green-50 p-2 rounded">
          ✓ Generated: {lastGeneratedName}
        </div>
      )}
    </div>
  );
}
