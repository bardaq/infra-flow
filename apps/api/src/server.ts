import fastify from "fastify";
import ws from "@fastify/websocket";
import { fastifyTRPCPlugin } from "@trpc/server/adapters/fastify";
import { serverConfig } from "@workspace/config/api.config";
import { rootRouter } from "./rootRouter";
import { createContext } from "./context";

const isDevelopment = process.env.NODE_ENV !== "production";

const server = fastify({
  logger: {
    level: isDevelopment ? "debug" : "info",
    transport: isDevelopment
      ? {
          target: "pino-pretty",
          options: {
            colorize: true,
          },
        }
      : undefined,
  },
});

// Debug middleware for development
if (isDevelopment) {
  server.addHook("onRequest", async (request, reply) => {
    console.log(
      `[${new Date().toISOString()}] ${request.method} ${request.url}`
    );
  });
}

server.register(ws);
server.register(fastifyTRPCPlugin, {
  prefix: serverConfig.prefix ?? "/trpc",
  useWSS: true,
  trpcOptions: { router: rootRouter, createContext },
});

// Enhanced health check endpoint
server.get("/health", async (request, reply) => {
  const uptime = process.uptime();
  const memoryUsage = process.memoryUsage();

  return {
    status: "ok",
    timestamp: new Date().toISOString(),
    uptime: `${Math.floor(uptime)}s`,
    memory: {
      used: `${Math.round(memoryUsage.heapUsed / 1024 / 1024)}MB`,
      total: `${Math.round(memoryUsage.heapTotal / 1024 / 1024)}MB`,
    },
    environment: process.env.NODE_ENV || "development",
    pid: process.pid,
  };
});

// Debug endpoint for development
if (isDevelopment) {
  server.get("/debug/info", async () => {
    return {
      config: serverConfig,
      routes: server.printRoutes(),
      env: {
        NODE_ENV: process.env.NODE_ENV,
        PORT: process.env.PORT,
      },
    };
  });
}

// Graceful shutdown handling
const gracefulShutdown = async (signal: string) => {
  console.log(`\n🛑 Received ${signal}, starting graceful shutdown...`);
  try {
    await server.close();
    console.log("✅ Server closed successfully");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error during shutdown:", error);
    process.exit(1);
  }
};

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

(async () => {
  try {
    const port = serverConfig.port ?? 2022;
    const host = "localhost";

    await server.listen({ port, host });

    console.log(`🚀 Server is running!`);
    console.log(`📍 Health check: http://${host}:${port}/health`);
    console.log(
      `🔌 tRPC endpoint: http://${host}:${port}${serverConfig.prefix ?? "/trpc"}`
    );

    if (isDevelopment) {
      console.log(`🐛 Debug info: http://${host}:${port}/debug/info`);
      console.log(`📝 Environment: ${process.env.NODE_ENV || "development"}`);
      console.log(`🔍 Process ID: ${process.pid}`);
    }
  } catch (err) {
    server.log.error("Failed to start server:", err);
    console.error("❌ Server startup failed:", err);
    process.exit(1);
  }
})();

