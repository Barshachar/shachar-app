const globalHolder = globalThis as typeof globalThis & {
  __cardcomProcessed?: Set<string>;
};

function getStore(): Set<string> {
  if (!globalHolder.__cardcomProcessed) {
    globalHolder.__cardcomProcessed = new Set();
  }
  return globalHolder.__cardcomProcessed;
}

export function hasProcessedTransaction(id: string | null | undefined): boolean {
  if (!id) {
    return false;
  }
  return getStore().has(id);
}

export function markTransactionProcessed(id: string | null | undefined): void {
  if (!id) {
    return;
  }
  getStore().add(id);
}

export function resetProcessedTransactions(): void {
  getStore().clear();
}
