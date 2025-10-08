'use client';

import { useRouter } from 'next/navigation';
import { useState, FormEvent } from 'react';

export default function SearchBar() {
  const router = useRouter();
  const [value, setValue] = useState('');

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const params = new URLSearchParams();
    if (value.trim()) {
      params.set('q', value.trim());
    }

    const url = params.toString() ? `/search?${params.toString()}` : '/search';
    router.push(url as any);
  };

  return (
    <form onSubmit={handleSubmit} className="hidden items-center gap-2 rounded-full border border-slate-200 bg-white/90 px-3 py-1.5 text-sm shadow-sm transition focus-within:border-emerald-500 md:flex">
      <input
        type="search"
        placeholder="חיפוש מהיר..."
        value={value}
        onChange={(event) => setValue(event.target.value)}
        className="w-44 bg-transparent text-slate-700 outline-none rtl:text-right"
      />
      <button type="submit" className="rounded-full bg-emerald-600 px-3 py-1 text-xs font-semibold text-white">
        חיפוש
      </button>
    </form>
  );
}
