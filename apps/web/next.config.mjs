/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ["@workspace/ui", "@infra-flow/api"],
  output: "standalone",
  outputFileTracingRoot: process.cwd(),
};

export default nextConfig;

