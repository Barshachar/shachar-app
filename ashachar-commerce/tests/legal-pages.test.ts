import { afterAll, beforeAll, describe, expect, test } from 'vitest';
import { spawn, type ChildProcess } from 'child_process';
import { once } from 'events';

const TEST_PORT = 3131;
const LEGAL_ROUTES = [
  { path: '/terms', heading: 'תנאי שימוש' },
  { path: '/privacy', heading: 'מדיניות פרטיות' },
  { path: '/shipping', heading: 'משלוחים והחזרות' },
  { path: '/accessibility', heading: 'הצהרת נגישות' }
];

let devServer: ChildProcess | undefined;
let serverLogs = '';

beforeAll(async () => {
  devServer = spawn('npm', ['run', 'dev', '--', '-p', String(TEST_PORT)], {
    cwd: process.cwd(),
    env: {
      ...process.env,
      NODE_ENV: 'development'
    },
    stdio: ['ignore', 'pipe', 'pipe']
  });

  if (!devServer.stdout || !devServer.stderr) {
    throw new Error('Failed to access dev server output streams');
  }

  devServer.stderr.on('data', (chunk) => {
    serverLogs += chunk.toString();
  });

  await new Promise<void>((resolve, reject) => {
    const timeout = setTimeout(() => {
      reject(new Error(`Next dev server did not start within timeout. Logs:\n${serverLogs}`));
    }, 60000);

    const onExit = (code: number | null) => {
      clearTimeout(timeout);
      reject(new Error(`Next dev server exited early with code ${code}. Logs:\n${serverLogs}`));
    };

    const onStdout = (chunk: Buffer) => {
      const text = chunk.toString();
      serverLogs += text;
      if (text.includes('ready - started server') || text.includes('Ready in')) {
        clearTimeout(timeout);
        devServer?.stdout?.off('data', onStdout);
        devServer?.off('exit', onExit);
        resolve();
      }
    };

    devServer.stdout.on('data', onStdout);
    devServer.once('exit', onExit);
  });
}, 120000);

afterAll(async () => {
  if (devServer) {
    devServer.kill('SIGTERM');
    await Promise.race([
      once(devServer, 'exit'),
      new Promise((resolve) => setTimeout(resolve, 5_000))
    ]);
  }
});

describe.sequential('legal pages', () => {
  for (const { path, heading } of LEGAL_ROUTES) {
    test(`${path} responds with 200 and contains heading`, async () => {
      const response = await fetch(`http://127.0.0.1:${TEST_PORT}${path}`);
      expect(response.status).toBe(200);
      const html = await response.text();
      expect(html).toContain('<h1');
      expect(html).toContain(heading);
    }, 20000);
  }
});
