export function assertLocalMode() {
  if (process.env.APP_DATA_MODE !== 'local') {
    throw new Response(JSON.stringify({ error: 'Local-only endpoint' }), { status: 403 });
  }
}
