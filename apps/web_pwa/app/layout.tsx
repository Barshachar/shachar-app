import type { Metadata } from 'next';
import './globals.css';
import Header from '@/components/Header';
import Footer from '@/components/Footer';
import { PricingModeProvider } from '@/app/providers';
import { getBaseUrl } from '@/lib/seo';

const baseUrl = getBaseUrl();
const HEEBO_FONT_URL = 'https://fonts.googleapis.com/css2?family=Heebo:wght@300;400;500;700&display=swap';

export const metadata: Metadata = {
  metadataBase: new URL(baseUrl),
  title: {
    default: 'א.שחר • אינסטלציה סיטונאית',
    template: '%s | א.שחר'
  },
  description: 'אתר מולטי־וונדור B2B/B2C בתחום האינסטלציה – קטלוג, עגלה ותשלום redirect ל-Cardcom.',
  openGraph: {
    title: 'א.שחר • אינסטלציה סיטונאית',
    description: 'מוצרים לסיטונאים ולקוחות פרטיים, תמחור B2B מותאם.',
    locale: 'he_IL',
    siteName: 'א.שחר • אינסטלציה סיטונאית',
    type: 'website'
  },
  twitter: {
    card: 'summary_large_image',
    title: 'א.שחר • אינסטלציה סיטונאית',
    description: 'קטלוג B2B/B2C מקומי לאביזרי אינסטלציה.',
    site: '@ashachar'
  },
  themeColor: '#059669'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="he" dir="rtl">
      <head>
        <link rel="preload" href={HEEBO_FONT_URL} as="style" crossOrigin="anonymous" />
        <link rel="stylesheet" href={HEEBO_FONT_URL} crossOrigin="anonymous" />
        <noscript>
          <link rel="stylesheet" href={HEEBO_FONT_URL} crossOrigin="anonymous" />
        </noscript>
      </head>
      <body className="min-h-screen flex flex-col bg-slate-50 text-slate-900">
        <PricingModeProvider>
          <Header />
          <main className="flex-1">{children}</main>
          <Footer />
        </PricingModeProvider>
      </body>
    </html>
  );
}
