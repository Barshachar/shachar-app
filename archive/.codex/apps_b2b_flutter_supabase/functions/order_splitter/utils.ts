export type OrderItemRecord = {
  vendor_company_id: string;
  line_total?: number;
};

export type VendorSplit = {
  vendor_company_id: string;
  status: string;
  total: number;
};

export function computeVendorSplits(items: OrderItemRecord[]): VendorSplit[] {
  const map = new Map<string, VendorSplit>();
  for (const item of items) {
    const key = item.vendor_company_id;
    const split = map.get(key) ?? {
      vendor_company_id: key,
      status: 'confirmed',
      total: 0,
    };
    split.total += Number(item.line_total ?? 0);
    map.set(key, split);
  }
  return Array.from(map.values());
}
