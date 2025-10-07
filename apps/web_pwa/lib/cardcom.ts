const REQUIRED_ENV = ['CARD_COM_PAGE_URL', 'CARD_COM_SUCCESS_URL', 'CARD_COM_ERROR_URL'] as const;

type CardcomEnv = Record<(typeof REQUIRED_ENV)[number], string>;

export function resolveCardcomEnv(): CardcomEnv {
  const entries = REQUIRED_ENV.map((key) => {
    const value = process.env[key];
    if (!value) {
      throw new Error(`Missing required Cardcom env var: ${key}`);
    }
    return [key, value];
  });
  return Object.fromEntries(entries) as CardcomEnv;
}

export function buildCardcomRedirect({
  sum,
  description,
  orderId
}: {
  sum: string;
  description: string;
  orderId: string;
}): string {
  if ((process.env.PAY_PROVIDER ?? 'cardcom') === 'test') {
    const base = process.env.CARD_COM_PAGE_URL || 'https://example.com/';
    const url = new URL(base);
    url.search = '';
    url.searchParams.set('ReturnData', `order_id=${orderId}`);
    return url.toString();
  }

  const env = resolveCardcomEnv();
  const pageUrl = new URL(env.CARD_COM_PAGE_URL);
  pageUrl.searchParams.set('sum', sum);
  pageUrl.searchParams.set('description', description);
  pageUrl.searchParams.set('ReturnData', `order_id=${orderId}`);
  pageUrl.searchParams.set('SuccessRedirectUrl', env.CARD_COM_SUCCESS_URL);
  pageUrl.searchParams.set('ErrorRedirectUrl', env.CARD_COM_ERROR_URL);
  return pageUrl.toString();
}
