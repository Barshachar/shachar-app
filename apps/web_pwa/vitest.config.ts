import { defineConfig } from 'vitest/config';
import { resolve } from 'node:path';

export default defineConfig({
  resolve: {
    alias: {
      '@': resolve(__dirname, '.'),
      '@/app': resolve(__dirname, 'app'),
      '@/components': resolve(__dirname, 'components'),
      '@/lib': resolve(__dirname, 'lib'),
      '@ashachar/contracts': resolve(__dirname, '../../packages/contracts/src')
    }
  },
  server: {
    port: 0
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    include: ['tests/**/*.test.ts']
  }
});
