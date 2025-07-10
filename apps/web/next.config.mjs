/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ["@workspace/ui", "@workspace/api"],
  output: "standalone",
  outputFileTracingRoot: process.cwd() + "/../../",
  outputFileTracingIncludes: {
    "/": ["../../packages/ui/src/**/*", "../api/src/**/*"],
  },
  // Enable experimental features for better HMR
  experimental: {
    // Optimize package imports for better HMR
    optimizePackageImports: ["@workspace/ui"],
  },
  // Configure webpack for better HMR with workspace packages
  webpack: (config, { dev }) => {
    if (dev) {
      // Ensure proper watching of workspace packages
      config.watchOptions = {
        ...config.watchOptions,
        ignored: /node_modules/,
      };
    }
    return config;
  },
};

export default nextConfig;

