import { promises as fs } from 'node:fs';
import { randomUUID } from 'node:crypto';

const LOG_PATH = '/tmp/ashachar-prod.log';

export async function logServerError(error: unknown, context?: { path?: string; method?: string }) {
  try {
    const timestamp = new Date().toISOString();
    const requestId = randomUUID();
    const serializedError = serializeError(error);
    const entry = [
      `time=${timestamp}`,
      `request_id=${requestId}`,
      context?.method ? `method=${context.method}` : null,
      context?.path ? `path=${context.path}` : null,
      `error=${serializedError}`
    ]
      .filter(Boolean)
      .join(' ');

    await fs.appendFile(LOG_PATH, `${entry}\n`, 'utf8');
  } catch (writeError) {
    console.error('Failed to write server error log', writeError);
  }
}

function serializeError(error: unknown): string {
  if (!error) {
    return 'unknown';
  }
  if (error instanceof Error) {
    return `${error.name}:${error.message}`;
  }
  if (typeof error === 'string') {
    return error;
  }
  try {
    return JSON.stringify(error);
  } catch (serializationError) {
    return 'unserializable-error';
  }
}
