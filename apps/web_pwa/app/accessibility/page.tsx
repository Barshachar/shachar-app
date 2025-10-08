import type { Metadata } from 'next';
import Breadcrumbs from '@/components/Breadcrumbs';
import { breadcrumbJsonLd, canonical } from '@/lib/seo';

const pagePath = '/accessibility';
const pageTitle = 'הצהרת נגישות';
const pageDescription =
  'הצהרת הנגישות של א.שחר מתארת התאמות דיגיטליות ופיזיות עבור לקוחות עסקיים ופרטיים באתר ובמרכז השירות.';

export const metadata: Metadata = {
  title: pageTitle,
  description: pageDescription,
  alternates: {
    canonical: canonical(pagePath)
  }
};

export default function AccessibilityPage() {
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
        אנו פועלים להנגשת חוויית הקטלוג, ניהול ההזמנות ותמיכת השירות ללקוחות עם מוגבלויות, בהתאם לתקן הישראלי 5568 ול-WCAG 2.1 רמה AA.
      </p>
      <section className="mt-8 space-y-3 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-slate-700">התאמות באתר הדיגיטלי</h2>
        <ul className="list-disc list-inside space-y-2 text-sm text-slate-600">
          <li>כותרות היררכיות, ניווט מקלדת ותמיכה מלאת RTL בדפדפני שולחן ונייד.</li>
          <li>צבעים עם ניגודיות שאינה נמוכה מ-4.5:1 ומצב כהה מותאם למערכות הפעלה.</li>
          <li>טפסי יצירת קשר עם תוויות ותמיכה בקוראי מסך.</li>
        </ul>
      </section>
      <section className="mt-6 space-y-3 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-slate-700">מרכז השירות ומחסן יבנה</h2>
        <ul className="list-disc list-inside space-y-2 text-sm text-slate-600">
          <li>עמדות שירות מונגשות ומעלית סחורה ללקוחות עם מוגבלות בתנועה.</li>
          <li>אפשרות לתיאום איסוף ללא יציאה מהרכב באמצעות מוקד ההזמנות.</li>
          <li>ספריית מפרטים בפורמט נגיש לפי דרישה בדוא"ל sales@ashachar.co.il.</li>
        </ul>
      </section>
      <p className="mt-6 text-sm text-slate-600">
        במידה ונתקלים בפער נגישות באתר או באפליקציית הניהול, נשמח לקבל פנייה לשירות הלקוחות בטלפון ‎08-933-1441 או בדוא"ל
        accessibility@ashachar.co.il.
      </p>
    </div>
  );
}
