/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ["@workspace/ui", "@workspace/api"],
  output: "standalone",
  outputFileTracingRoot: process.cwd() + "/../../",
  outputFileTracingIncludes: {
    "/": ["../../packages/ui/src/**/*", "../api/src/**/*"],
  },
};

export default nextConfig;

