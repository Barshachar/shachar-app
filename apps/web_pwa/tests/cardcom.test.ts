import { buildCardcomRedirect } from '@/lib/cardcom';

describe('buildCardcomRedirect', () => {
  it('builds a redirect URL with required params', () => {
    const url = buildCardcomRedirect({
      sum: '10.00',
      description: 'Order 1',
      orderId: 'abc-123'
    });

    expect(url).toContain('sum=10.00');
    expect(url).toMatch(/description=Order(%20|\+)1/);

    const parsed = new URL(url);
    const params = parsed.searchParams;

    expect(params.get('ReturnData')).toBe('order_id=abc-123');
    expect(params.get('SuccessRedirectUrl')).toBe(process.env.CARD_COM_SUCCESS_URL);
    expect(params.get('ErrorRedirectUrl')).toBe(process.env.CARD_COM_ERROR_URL);
  });
});
