import { NextResponse, NextRequest } from 'next/server';
import { ADMIN_COOKIE, evaluateAdminAccess } from '@/lib/admin/access';

const ADMIN_PREFIX = '/admin';

export function middleware(request: NextRequest) {
  const { pathname, search } = request.nextUrl;
  const isAdminApi = pathname.startsWith('/api/admin/');
  const isAdminUI = pathname.startsWith(ADMIN_PREFIX);
  const isLocal = process.env.APP_DATA_MODE === 'local';

  if (!isLocal && !isAdminApi && !isAdminUI) {
    return new NextResponse('PWA runs in local-only mode', { status: 503 });
  }

  if (!isAdminUI) {
    return NextResponse.next();
  }

  const status = evaluateAdminAccess(request.cookies.get(ADMIN_COOKIE)?.value);

  if (status === 'missing-pin') {
    return new NextResponse('ADMIN_PIN is required to access /admin', { status: 403 });
  }

  if (pathname.startsWith('/admin/login')) {
    if (status === 'ok') {
      const redirectUrl = request.nextUrl.clone();
      redirectUrl.pathname = '/admin/catalog';
      redirectUrl.search = '';
      return NextResponse.redirect(redirectUrl);
    }
    return NextResponse.next();
  }

  if (status === 'ok') {
    return NextResponse.next();
  }

  const loginUrl = request.nextUrl.clone();
  loginUrl.pathname = '/admin/login';
  const redirectTarget = `${pathname}${search}`;
  loginUrl.searchParams.set('redirect', redirectTarget);
  return NextResponse.redirect(loginUrl);
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)']
};
