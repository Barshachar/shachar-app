import type { Metadata } from 'next';
import Breadcrumbs from '@/components/Breadcrumbs';
import { breadcrumbJsonLd, canonical } from '@/lib/seo';

const pagePath = '/shipping';
const pageTitle = 'משלוחים והחזרות';
const pageDescription =
  'מדיניות משלוחים והחזרות של א.שחר: זמני אספקה, תיאום להזמנות כבדים והחזרת ציוד אינסטלציה.';

export const metadata: Metadata = {
  title: pageTitle,
  description: pageDescription,
  alternates: {
    canonical: canonical(pagePath)
  }
};

export default function ShippingPage() {
  const breadcrumbLd = breadcrumbJsonLd([
    { name: 'דף הבית', url: canonical('/') },
    { name: pageTitle, url: canonical(pagePath) }
  ]);

  return (
    <div className="mx-auto max-w-3xl px-4 py-12">
      <script
        type="application/ld+json"
        suppressHydrationWarning
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbLd) }}
      />
      <Breadcrumbs items={[{ label: 'דף הבית', href: '/' }, { label: pageTitle }]} />
      <h1 className="text-3xl font-bold text-slate-800">{pageTitle}</h1>
      <p className="mt-3 text-sm text-slate-600">
        אנו מפעילים מערך הפצה ארצי עם שילוב בין צי חלוקה פנימי ושילוח ייעודי לפרויקטים כדי לאפשר אספקה אמינה ללקוחות קבלניים ופרטיים.
      </p>
      <section className="mt-8 space-y-3 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-slate-700">זמני אספקה ותיאום</h2>
        <ul className="list-disc list-inside space-y-2 text-sm text-slate-600">
          <li>המרכז וגוש דן: אספקה עד 2 ימי עסקים להזמנות ברירת מחדל.</li>
          <li>דרום, צפון ופריפריה: אספקה עד 5 ימי עסקים, בכפוף לזמינות מסלול.</li>
          <li>אתרי בנייה פעילים דורשים תיאום חלון פריקה עם מחלקת התפעול.</li>
        </ul>
      </section>
      <section className="mt-6 space-y-3 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-slate-700">החזרות והחלפות</h2>
        <ul className="list-disc list-inside space-y-2 text-sm text-slate-600">
          <li>ניתן להחזיר מוצרים תקינים באריזה מקורית עד 14 יום ממועד האספקה.</li>
          <li>מוצרים שיוצרו לפי הזמנה או חיתוכים מיוחדים אינם ניתנים להחזרה.</li>
          <li>דיווח על פריט פגום יתבצע עד 48 שעות ויטופל דרך מוקד השירות.</li>
        </ul>
      </section>
    </div>
  );
}
