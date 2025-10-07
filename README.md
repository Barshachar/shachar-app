# א.שחר Commerce (Next.js)

פלטפורמת B2B/B2C מולטי־וונדור המבוססת על Next.js 14, Tailwind ו-Supabase. האתר מחליף את תצורת ה-WooCommerce הקיימת ומספק קטלוג מוצרים, עגלת קניות, תשלום Redirect ל-Cardcom ותמיכה מלאה ב-RTL.

## דרישות מוקדמות

- Node.js 18+
- Supabase Project (Postgres + RLS)
- Cardcom Page Redirect (דף 4) עם Success/Error/Notify URLs מוגדרים

## התקנה והפעלה

```bash
npm install
npm run dev
```

### משתני סביבה

העתיקו את `.env.example` ל-`.env.local` ועדכנו את הערכים:

```
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE=...
SESSION_COOKIE_NAME=ashachar_sid
SITE_NAME=א.שחר • אינסטלציה סיטונאית
SITE_PHONE=08-933-1441
SITE_ADDRESS=הירקון 13, יבנה
CARD_COM_PAGE_URL=https://secure.cardcom.solutions/e/<CARD_PAGE>/
CARD_COM_SUCCESS_URL=https://localhost:3000/success
CARD_COM_ERROR_URL=https://localhost:3000/fail
```

## Supabase

1. הריצו את קבצי ה-SQL תחת `supabase/schema.sql`, `supabase/policies.sql` ו-`supabase/seed.sql` בממשק ה-SQL של Supabase לפי הסדר.
2. וודאו שקיימות המדיניות (RLS) וש-RPC `cart_with_prices` ו-`add_to_cart` זמינים. הקוד משתמש ב-`cart_items_view` לצורך הצגת פריטים עם נתוני וריאנט.
3. הוסיפו את Notify URL של Cardcom ל-`/api/cardcom/webhook`.

## מבנה פרויקט

```
app/              # Next.js App Router (עמודים, API Routes, מטאדאטה)
components/       # קומפוננטים מונחי מחיר/Vendor/Cart
lib/              # לוגיקה עסקית: Supabase, תמחור, Cardcom, Session
public/           # תמונות הירו, קטגוריות וספקים
supabase/         # סכימה, מדיניות RLS ונתונים לדמו
tests/            # בדיקות Vitest (Formatter, Cardcom, Pricing, RLS)
```

## בדיקות

```bash
npm run test
```

הבדיקות מכסות:

- `formatILS` – עמידה בפרמטר מטבע (ILS).
- `buildCardcomRedirect` – וידוא פרמטרי Redirect לסליקה.
- `pricing` – חישוב מחירי B2B/B2C ועמידה בדרישות Tier.
- `supabase/policies.sql` – בדיקת רגרסיית RLS (הפעלת RLS על cart + public read על מוצרים).

## זרימת תשלום (Cardcom)

1. העגלה נשמרת בקוקי (`SESSION_COOKIE_NAME`) ומאוכלסת דרך `api/cart/*`.
2. `POST /api/checkout` יוצר הזמנה במצב `pending` ומחזיר Redirect לדף Cardcom עם פרמטר ReturnData = `order_id=<uuid>`.
3. `POST /api/cardcom/webhook` מקבל Form-Data מ-Cardcom, קורא את `ResponseCode`, ומעדכן את סטטוס ההזמנה ל-`paid`/`failed`.
4. עמודי `/success` ו-`/fail` משמשים נחיתה לאחר התשלום.

## RTL + B2B/B2C

- כל הדפים מוגדרים `lang="he" dir="rtl"` ומבוססי Heebo.
- המחירים ניתנים למיתוג B2C/B2B דרך `PricingModeProvider` ו-`PricingModeToggle`.
- קומפוננטת `<Price />` מציגה ₪ בשפה העברית.

## שלבים הבאים

- חיבור התחברות עסקים (Supabase Auth + price_group פר חשבון).
- חיזוק RLS לעומק (קישור cart/order ל-`auth.uid`).
- בדיקות אינטגרציה מול Cardcom Sandbox לפני העלאה לפרודקשן.
