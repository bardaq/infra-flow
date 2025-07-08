import { testRouter } from "./routers/test";
import { subscriptionTestRouter } from "./routers/subscriptitonTest";
import { router } from "./trpc";
import { createCallerFactory } from "./trpc";

export const rootRouter = router({
  test: testRouter,
  subscriptionTest: subscriptionTestRouter,
});

export type TrpcRouter = typeof rootRouter;

/**
 * Create a server-side caller for the tRPC API.
 * @example
 * const trpc = createCaller(createContext);
 * const res = await trpc.post.all();
 *       ^? Post[]
 */
export const createCaller = createCallerFactory(rootRouter);

