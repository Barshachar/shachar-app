import CartView from '@/components/CartView';
import { ensureSessionId, readSessionId } from '@/lib/session';
import { fetchCartItems } from '@/lib/data';

export const dynamic = 'force-dynamic';

export default async function CartPage() {
  const sessionId = readSessionId() ?? ensureSessionId();
  const items = await fetchCartItems(sessionId);

  return (
    <div className="mx-auto max-w-5xl px-4 py-12">
      <h1 className="text-3xl font-bold text-slate-800">העגלה שלך</h1>
      <p className="mt-2 text-sm text-slate-600">
        העגלה נשמרת אוטומטית בקוקי Session. תוכלו להמשיך לגלוש ולהשלים רכישה בכל רגע.
      </p>
      <div className="mt-8">
        <CartView initialItems={items} />
      </div>
    </div>
  );
}
