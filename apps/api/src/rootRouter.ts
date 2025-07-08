import { testRouter } from "./routers/test";
import { subscriptionTestRouter } from "./routers/subscriptitonTest";
import { router } from "./trpc";

export const rootRouter = router({
  test: testRouter,
  subscriptionTest: subscriptionTestRouter,
});

export type TrpcRouter = typeof rootRouter;

