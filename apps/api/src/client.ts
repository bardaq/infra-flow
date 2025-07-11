import type { TrpcRouter } from "./rootRouter";
import {
  createTRPCClient,
  createWSClient,
  httpBatchLink,
  splitLink,
  wsLink,
} from "@trpc/client";
import superjson from "superjson";
import { serverConfig } from "@workspace/config/api.config";

const { port, prefix } = serverConfig;
const urlEnd = `localhost:${port}${prefix}`;
const wsClient = createWSClient({ url: `ws://${urlEnd}` });
// Ok, but when to close...
// await wsClient.close();

export const trpc = createTRPCClient<TrpcRouter>({
  links: [
    splitLink({
      condition(op) {
        return op.type === "subscription";
      },
      true: wsLink({ client: wsClient, transformer: superjson }),
      false: httpBatchLink({
        url: `http://${urlEnd}`,
        transformer: superjson,
      }),
    }),
  ],
});

