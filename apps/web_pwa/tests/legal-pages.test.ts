import { afterAll, beforeAll, describe, expect, test } from 'vitest';
import { spawn, type ChildProcess } from 'child_process';
import { once } from 'events';

const runLegal = process.env.LEGAL_PAGES_E2E === "1";

const TEST_PORT = 3131;
const LEGAL_ROUTES = [
  { path: '/terms', heading: 'תנאי שימוש' },
  { path: '/privacy', heading: 'מדיניות פרטיות' },
  { path: '/shipping', heading: 'משלוחים והחזרות' },
  { path: '/accessibility', heading: 'הצהרת נגישות' }
];

let devServer: ChildProcess | undefined;
let serverLogs = '';
let serverUnavailable = false;

beforeAll(async () => {
  if (!runLegal) return;
  try {
    devServer = spawn(
      'npm',
      ['run', 'dev', '--', '-p', String(TEST_PORT), '-H', '127.0.0.1'],
      {
        cwd: process.cwd(),
        env: {
          ...process.env,
          NODE_ENV: 'development',
          HOST: '127.0.0.1'
        },
        stdio: ['ignore', 'pipe', 'pipe']
      }
    );

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

      const server = devServer;
      const stdout = server?.stdout;
      if (!server || !stdout) {
        clearTimeout(timeout);
        reject(new Error(`Next dev server stdout not available. Logs:\n${serverLogs}`));
        return;
      }

      const onStdout = (chunk: Buffer) => {
        const text = chunk.toString();
        serverLogs += text;
        if (text.includes('ready - started server') || text.includes('Ready in')) {
          clearTimeout(timeout);
          stdout.off('data', onStdout);
          server.off('exit', onExit);
          resolve();
        }
      };

      stdout.on('data', onStdout);
      server.once('exit', onExit);
    });
  } catch (error) {
    serverUnavailable = /operation not permitted/i.test(String(error));
    if (!serverUnavailable) {
      throw error;
    }
  }
}, 120000);

afterAll(async () => {
  if (!runLegal) return;
  if (devServer) {
    devServer.kill('SIGTERM');
    await Promise.race([
      once(devServer, 'exit'),
      new Promise((resolve) => setTimeout(resolve, 5_000))
    ]);
  }
});

(runLegal ? describe : describe.skip)('legal pages', () => {
  for (const { path, heading } of LEGAL_ROUTES) {
    test(`${path} responds with 200 and contains heading`, async () => {
      if (serverUnavailable) {
        console.warn(
          `Skipping legal pages suite: sandbox prevented binding to ${TEST_PORT}`
        );
        return;
      }
      const response = await fetch(`http://127.0.0.1:${TEST_PORT}${path}`);
      expect(response.status).toBe(200);
      const html = await response.text();
      expect(html).toContain('<h1');
      expect(html).toContain(heading);
    }, 20000);
  }
});
