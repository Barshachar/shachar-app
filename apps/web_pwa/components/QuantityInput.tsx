'use client';

export default function QuantityInput({
  value,
  onChange,
  min = 1
}: {
  value: number;
  min?: number;
  onChange: (value: number) => void;
}) {
  const decrement = () => {
    const next = Math.max(min, value - 1);
    onChange(next);
  };

  const increment = () => {
    onChange(value + 1);
  };

  return (
    <div className="inline-flex items-center gap-2 rounded-full border border-slate-200 bg-white px-3 py-1 text-sm">
      <button type="button" onClick={decrement} className="px-2 text-slate-500 hover:text-emerald-600">
        −
      </button>
      <span className="w-6 text-center font-semibold">{value}</span>
      <button type="button" onClick={increment} className="px-2 text-slate-500 hover:text-emerald-600">
        +
      </button>
    </div>
  );
}
