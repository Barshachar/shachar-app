import { NextRequest, NextResponse } from 'next/server';
import { logServerError } from '@/lib/error-logger';
import { assertLocalMode } from '@/lib/local-mode';

export async function POST(request: NextRequest) {
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  try {
    const body = await request.json().catch(() => ({}));
    const { message, digest, path } = body as {
      message?: string;
      digest?: string | null;
      path?: string;
    };
    const errorPayload = {
      message: message ?? 'Unknown client reported error',
      digest: digest ?? null
    };
    await logServerError(errorPayload, {
      path: path || request.nextUrl.pathname,
      method: request.method
    });

    return NextResponse.json({ ok: true });
  } catch (error) {
    console.error('log-error route failed', error);
    return NextResponse.json({ ok: false }, { status: 500 });
  }
}
