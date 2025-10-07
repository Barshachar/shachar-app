'use client';

import { useMemo } from 'react';
import { formatILS } from '@/lib/formatter';

export default function Price({
  valueCents,
  note,
  highlight = false
}: {
  valueCents: number;
  note?: string;
  highlight?: boolean;
}) {
  const formatted = useMemo(() => formatILS(valueCents), [valueCents]);

  return (
    <div className="flex flex-col">
      <span className={highlight ? 'text-2xl font-bold text-emerald-700' : 'text-lg font-semibold text-slate-800'}>
        {formatted}
      </span>
      {note ? <span className="text-xs text-slate-500">{note}</span> : null}
    </div>
  );
}
