import CheckoutView from '@/components/CheckoutView';
import { ensureSessionId, readSessionId } from '@/lib/session';
import { fetchCartItems } from '@/lib/data';

export const dynamic = 'force-dynamic';

export default async function CheckoutPage() {
  const sessionId = readSessionId() ?? ensureSessionId();
  const items = await fetchCartItems(sessionId);

  return (
    <div className="mx-auto max-w-3xl px-4 py-12">
      <h1 className="text-3xl font-bold text-slate-800">תשלום והזמנה</h1>
      <p className="mt-2 text-sm text-slate-600">
        נבנה הפניה ל-Cardcom (דף 4) עם סכום העגלה. חזרו לעמוד זה לאחר התשלום.
      </p>
      <div className="mt-8">
        <CheckoutView initialItems={items} />
      </div>
    </div>
  );
}
