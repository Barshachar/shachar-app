'use client';

import { createContext, useContext, useEffect, useMemo, useState } from 'react';

export type PricingMode = 'b2c' | 'b2b';

type PricingModeContextValue = {
  mode: PricingMode;
  setMode: (mode: PricingMode) => void;
  priceGroup: string | null;
};

const PricingModeContext = createContext<PricingModeContextValue | undefined>(undefined);

const STORAGE_KEY = 'ashachar-pricing-mode';

export function PricingModeProvider({ children }: { children: React.ReactNode }) {
  const [mode, setMode] = useState<PricingMode>('b2c');

  useEffect(() => {
    const stored = window.localStorage.getItem(STORAGE_KEY) as PricingMode | null;
    if (stored === 'b2b' || stored === 'b2c') {
      setMode(stored);
    }
  }, []);

  const updateMode = (next: PricingMode) => {
    setMode(next);
    window.localStorage.setItem(STORAGE_KEY, next);
  };

  const value = useMemo<PricingModeContextValue>(
    () => ({ mode, setMode: updateMode, priceGroup: null }),
    [mode]
  );

  return <PricingModeContext.Provider value={value}>{children}</PricingModeContext.Provider>;
}

export function usePricingMode() {
  const ctx = useContext(PricingModeContext);
  if (!ctx) {
    throw new Error('usePricingMode must be used within PricingModeProvider');
  }
  return ctx;
}
