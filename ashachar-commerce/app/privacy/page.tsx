import type { Metadata } from 'next';
import Breadcrumbs from '@/components/Breadcrumbs';
import { breadcrumbJsonLd, canonical } from '@/lib/seo';

const pagePath = '/privacy';
const pageTitle = 'מדיניות פרטיות';
const pageDescription =
  'מדיניות פרטיות עבור לקוחות א.שחר: שמירת נתונים בסופבייס עם RLS, טיפול בתשלומים דרך Cardcom והגנה על מידע רגיש.';

export const metadata: Metadata = {
  title: pageTitle,
  description: pageDescription,
  alternates: {
    canonical: canonical(pagePath)
  }
};

export default function PrivacyPage() {
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
        אנו מנהלים נתוני לקוחות וספקים תחת הגנות Supabase RLS ומקפידים על הצפנה בצד הלקוח ובצד השרת בכל תהליך רישום, הזמנה ותמיכה.
      </p>
      <section className="mt-8 space-y-3 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-slate-700">איסוף ושימוש בנתונים</h2>
        <ul className="list-disc list-inside space-y-2 text-sm text-slate-600">
          <li>פרטי התחברות וניהול הרשאות נשמרים בסופבייס ומוגנים לפי תפקיד, ספק או חטיבה.</li>
          <li>מידע תפעולי כגון הזמנות, הצעות מחיר והיסטוריית משלוחים משמש לתמיכה ושיפור השירות בלבד.</li>
          <li>מדדי שימוש אנונימיים משמשים לניתוח תקלות ולשיפור חוויית הקטלוג.</li>
        </ul>
      </section>
      <section className="mt-6 space-y-3 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-slate-700">אבטחה וזכויות משתמש</h2>
        <ul className="list-disc list-inside space-y-2 text-sm text-slate-600">
          <li>תשלומים מכוונים אל Cardcom ואינם נשמרים בבסיס הנתונים של א.שחר.</li>
          <li>ניתן לעדכן או למחוק נתונים אישיים באמצעות פנייה לשירות הלקוחות בדוא"ל sales@ashachar.co.il.</li>
          <li>התראות אבטחה נשלחות למנהלי חשבון בעת שינוי גישה או יצירת משתמש חדש.</li>
        </ul>
      </section>
    </div>
  );
}
