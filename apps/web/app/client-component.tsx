"use client";

import { useState } from "react";
import { Button } from "@workspace/ui/components/button";
import { API } from "@/lib/trpc/API.client";

export function ClientComponent() {
  const [username, setUsername] = useState("");

  const versionQuery = API.test.version.useQuery();
  const helloQuery = API.test.hello.useQuery(
    { echo: username || null },
    { enabled: false }
  );

  const handleFetchHello = () => {
    helloQuery.refetch();
  };

  return (
    <div className="border p-4 rounded-lg">
      <h3 className="font-semibold mb-2">Client-side tRPC</h3>

      <div className="space-y-2">
        <div>
          <p className="text-sm text-gray-600">Auto-fetched version:</p>
          <p>{versionQuery.data?.version || "Loading..."}</p>
        </div>

        <div className="space-y-2">
          <input
            type="text"
            placeholder="Enter username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            className="border rounded px-2 py-1"
          />
          <Button onClick={handleFetchHello} size="sm">
            Fetch Hello
          </Button>
          {helloQuery.data && <p className="text-sm">{helloQuery.data.text}</p>}
        </div>
      </div>
    </div>
  );
}

