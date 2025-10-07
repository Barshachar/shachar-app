import { NextResponse } from 'next/server';
import { ADMIN_COOKIE, getAdminPin } from '@/lib/admin/access';

function resolveRedirect(target: unknown): string {
  if (typeof target !== 'string') {
    return '/admin/catalog';
  }
  return target.startsWith('/admin') ? target : '/admin/catalog';
}

export async function POST(request: Request) {
  const pin = getAdminPin();
  if (!pin) {
    return NextResponse.json({ error: 'ADMIN_PIN not configured' }, { status: 403 });
  }

  const formData = await request.formData();
  const submittedPin = formData.get('pin');
  const redirectTo = resolveRedirect(formData.get('redirect'));

  if (submittedPin === pin) {
    const response = NextResponse.redirect(new URL(redirectTo, request.url));
    response.cookies.set(ADMIN_COOKIE, pin, {
      httpOnly: true,
      sameSite: 'lax',
      path: '/admin',
      secure: process.env.NODE_ENV === 'production',
      maxAge: 60 * 60 * 24
    });
    return response;
  }

  const url = new URL('/admin/login', request.url);
  url.searchParams.set('error', '1');
  url.searchParams.set('redirect', redirectTo);
  return NextResponse.redirect(url);
}
