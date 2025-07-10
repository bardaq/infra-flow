import { z } from "zod";
import { publicProcedure, router } from "../trpc";

export const testRouter = router({
  version: publicProcedure.query(() => {
    return { version: "0.49.0" };
  }),
  hello: publicProcedure
    .input(z.object({ echo: z.string().nullish() }).nullish())
    .query(({ input, ctx }) => {
      return {
        text: `hello world ${input?.echo || "world"}`,
      };
    }),
});

