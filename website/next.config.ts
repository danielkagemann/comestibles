import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "export",
  basePath: "/comestibles",
  assetPrefix: "/comestibles/",
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
