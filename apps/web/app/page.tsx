import { Button } from "@workspace/ui/components/button";
import { API } from "@/lib/trpc/API.server";
import { ClientComponent } from "./client-component";
import { FileTestForm } from "@/components/FileTestForm";

export default async function Page() {
  const versionData = await API.test.version();

  return (
    <div className="flex items-center justify-center min-h-svh p-4">
      <div className="flex flex-col items-center justify-center gap-8 max-w-4xl w-full">
        <h1 className="text-2xl font-bold">Hello World</h1>
        <div className="text-center">
          <p className="text-sm text-gray-600">Server-side tRPC data:</p>
          <p>Version: {versionData.version}</p>
        </div>
        <ClientComponent />
        <FileTestForm />
        <Button size="sm">Button</Button>
      </div>
    </div>
  );
}

