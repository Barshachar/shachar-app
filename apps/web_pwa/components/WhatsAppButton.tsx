'use client';

import { useMemo } from 'react';

const SITE_PHONE = process.env.SITE_PHONE || '08-933-1441';

export default function WhatsAppButton() {
  const href = useMemo(() => {
    const digits = SITE_PHONE.replace(/[^\d+]/g, '');
    return `https://wa.me/${digits}`;
  }, []);

  return (
    <a
      href={href}
      target="_blank"
      rel="noreferrer"
      className="fixed bottom-6 left-6 flex h-12 w-12 items-center justify-center rounded-full bg-emerald-600 text-white shadow-lg transition hover:bg-emerald-700"
      aria-label="צ'אט WhatsApp"
    >
      ☏
    </a>
  );
}
