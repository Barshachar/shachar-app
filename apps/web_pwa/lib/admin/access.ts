export const ADMIN_COOKIE = 'admin_pin';

type MaybeString = string | null | undefined;

export function getAdminPin(): string | null {
  const value = process.env.ADMIN_PIN;
  if (!value) {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length ? trimmed : null;
}

export type AdminAccessState = 'ok' | 'missing-pin' | 'unauthorized';

export function evaluateAdminAccess(cookieValue: MaybeString): AdminAccessState {
  const pin = getAdminPin();
  if (!pin) {
    return 'missing-pin';
  }
  if (!cookieValue || cookieValue !== pin) {
    return 'unauthorized';
  }
  return 'ok';
}

export function isAdminReadOnly(): boolean {
  const value = process.env.ADMIN_READONLY ?? process.env.NEXT_PUBLIC_ADMIN_READONLY;
  if (!value) {
    return false;
  }
  const normalized = value.trim().toLowerCase();
  return normalized === '1' || normalized === 'true' || normalized === 'yes';
}
