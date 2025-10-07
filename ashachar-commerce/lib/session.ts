import { cookies } from 'next/headers';
import { randomUUID } from 'crypto';

const DEFAULT_COOKIE_NAME = 'ashachar_sid';

function resolveCookieName() {
  return process.env.SESSION_COOKIE_NAME || DEFAULT_COOKIE_NAME;
}

export function readSessionId(): string | null {
  const store = cookies();
  const existing = store.get(resolveCookieName());
  return existing?.value ?? null;
}

export function ensureSessionId(): string {
  const store = cookies();
  const cookieName = resolveCookieName();
  const existing = store.get(cookieName);
  if (existing?.value) {
    return existing.value;
  }
  const newSession = randomUUID();
  store.set(cookieName, newSession, {
    path: '/',
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: 60 * 60 * 24 * 30
  });
  return newSession;
}
