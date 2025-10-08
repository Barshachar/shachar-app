import type { Metadata } from 'next';
import Breadcrumbs from '@/components/Breadcrumbs';
import { breadcrumbJsonLd, canonical } from '@/lib/seo';

const pagePath = '/terms';
const pageTitle = 'תנאי שימוש';
const pageDescription =
  'תנאי השימוש בפלטפורמת הסחר של א.שחר מגדירים את ההתקשרות עם לקוחות עסקיים ופרטיים בהזמנות מוצרים לאינסטלציה.';

export const metadata: Metadata = {
  title: pageTitle,
  description: pageDescription,
  alternates: {
    canonical: canonical(pagePath)
  }
};

export default function TermsPage() {
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
        שימוש בפלטפורמת א.שחר מהווה הסכמה לתנאים אלו ולהתנהלות סחר הוגנת בין ספקים, קבלנים ולקוחות פרטיים.
      </p>
      <section className="mt-8 space-y-3 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-slate-700">התקשרות והזמנות</h2>
        <ul className="list-disc list-inside space-y-2 text-sm text-slate-600">
          <li>המחירים המוצגים ללקוחות רשומים מבוססים על הסכמי הסחר המאושרים לחשבון.</li>
          <li>אישור הזמנה סופי כפוף לזמינות מלאי במחסן יבנה ולבדיקת מסגרת אשראי.</li>
          <li>ציוד ייעודי או ייבוא מיוחד מחייבים התחייבות הזמנה כתובה ואינם ניתנים לביטול לאחר היציאה לדרכה.</li>
        </ul>
      </section>
      <section className="mt-6 space-y-3 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-slate-700">שימוש תקין בפלטפורמה</h2>
        <ul className="list-disc list-inside space-y-2 text-sm text-slate-600">
          <li>המשתמש אחראי לעדכן פרטי קשר ומשלוח מדויקים עבור אתרי הפרויקט או המחסן.</li>
          <li>גישה לקטלוג ספקים חיצוניים מוענקת בהתאם להרשאות תפקיד בארגון.</li>
          <li>א.שחר רשאית לסיים או להגביל שימוש במערכת במקרה של פעילות חריגה או הפרת נהלי אבטחת מידע.</li>
        </ul>
      </section>
    </div>
  );
}
