export const LOCAL_MODE_CODE = 'LOCAL_MODE_REQUIRED';
export const DEFAULT_LOCAL_MODE_MESSAGE = 'This endpoint is allowed only in APP_DATA_MODE=local';

export function localModeError(message: string = DEFAULT_LOCAL_MODE_MESSAGE): Response {
  return new Response(JSON.stringify({ error: { code: LOCAL_MODE_CODE, message } }), {
    status: 503,
    headers: { 'content-type': 'application/json' }
  });
}

export function assertLocalMode(): void {
  if (process.env.APP_DATA_MODE !== 'local') {
    throw localModeError();
  }
}

export function shouldUseLocalData(): boolean {
  if (process.env.NODE_ENV === 'test') {
    return true;
  }
  return process.env.APP_DATA_MODE === 'local';
}
