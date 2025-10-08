/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: {
    typedRoutes: true,
    externalDir: true
  },
  i18n: {
    locales: ['he'],
    defaultLocale: 'he'
  }
};

module.exports = nextConfig;
