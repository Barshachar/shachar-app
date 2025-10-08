import { NextRequest, NextResponse } from 'next/server';
import { ADMIN_COOKIE, evaluateAdminAccess } from './access';

export function guardAdminApiRequest(request: NextRequest): NextResponse | null {
  const status = evaluateAdminAccess(request.cookies.get(ADMIN_COOKIE)?.value);
  if (status === 'ok') {
    return null;
  }
  if (status === 'missing-pin') {
    return NextResponse.json({ error: 'ADMIN_PIN not configured' }, { status: 403 });
  }
  return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
}
