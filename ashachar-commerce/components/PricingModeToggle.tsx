'use client';

import { usePricingMode } from '@/app/providers';
import clsx from 'clsx';

const options = [
  { value: 'b2c', label: 'מחירי קמעונאות' },
  { value: 'b2b', label: 'מחירי עסקים' }
] as const;

export default function PricingModeToggle() {
  const { mode, setMode } = usePricingMode();

  return (
    <div className="flex items-center gap-2 rounded-full bg-slate-100 p-1">
      {options.map((option) => (
        <button
          key={option.value}
          type="button"
          onClick={() => setMode(option.value)}
          className={clsx(
            'rounded-full px-3 py-1 text-xs font-semibold transition-colors',
            mode === option.value
              ? 'bg-emerald-600 text-white shadow'
              : 'text-slate-500 hover:text-emerald-600'
          )}
        >
          {option.label}
        </button>
      ))}
    </div>
  );
}
