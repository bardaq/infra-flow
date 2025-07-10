import "server-only";

import { createHydrationHelpers } from "@trpc/react-query/rsc";
import { headers } from "next/headers";
import { cache } from "react";

import { createCaller, type TrpcRouter } from "@workspace/api/rootRouter";
import { createTRPCContext } from "@workspace/api/trpc";
import { createQueryClient } from "./queryClient";

/**
 * This wraps the `createTRPCContext` helper and provides the required context for the tRPC API when
 * handling a tRPC call from a React Server Component.
 */
const createContext = cache(async () => {
  const heads = new Headers(await headers());
  heads.set("x-trpc-source", "rsc");

  return createTRPCContext({
    headers: heads,
  });
});

const getQueryClient = cache(createQueryClient);
const caller = createCaller(createContext);

const hydrationHelpers = createHydrationHelpers<TrpcRouter>(
  caller,
  getQueryClient
);

export const API: ReturnType<
  typeof createHydrationHelpers<TrpcRouter>
>["trpc"] = hydrationHelpers.trpc;

export const HydrateClient = hydrationHelpers.HydrateClient;

