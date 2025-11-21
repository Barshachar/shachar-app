import type { Database, Json } from './supabase';

type DbProductRow = Database['public']['Tables']['products']['Row'];
type DbVariantRow = Database['public']['Tables']['product_variants']['Row'];

type LocalizedName = {
  he?: string;
  en?: string;
};

function toRecord(value: Json | null | undefined): Record<string, unknown> | undefined {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return undefined;
  }
  return value as Record<string, unknown>;
}

function toLocalizedName(value: Json | null): LocalizedName | undefined {
  const record = toRecord(value);
  if (!record) {
    return undefined;
  }
  const translated: LocalizedName = {};
  if (typeof record.he === 'string') {
    translated.he = record.he;
  }
  if (typeof record.en === 'string') {
    translated.en = record.en;
  }
  return Object.keys(translated).length ? translated : undefined;
}

export type ProductDto = {
  id: string;
  vendorCompanyId: string;
  categoryId: string | null;
  sku: string;
  uom: string;
  active: boolean;
  leadTimeDays?: number;
  moq?: number;
  packSize?: number;
  localizedName?: LocalizedName;
  attributes?: Record<string, unknown>;
};

export type ProductVariantDto = {
  id: string;
  productId: string;
  sku: string;
  uom: string;
  active: boolean;
  barcode?: string | null;
  attributes: Record<string, unknown>;
};

export function fromDbProductRow(row: DbProductRow): ProductDto {
  return {
    id: row.id,
    vendorCompanyId: row.vendor_company_id,
    categoryId: row.category_id,
    sku: row.sku,
    uom: row.uom,
    active: row.active,
    leadTimeDays: typeof row.lead_time === 'number' ? row.lead_time : undefined,
    moq: typeof row.moq === 'number' ? row.moq : undefined,
    packSize: typeof row.pack_size === 'number' ? row.pack_size : undefined,
    localizedName: toLocalizedName(row.name),
    attributes: toRecord(row.description)
  };
}

export function fromDbVariantRow(row: DbVariantRow): ProductVariantDto {
  return {
    id: row.id,
    productId: row.product_id,
    sku: row.sku,
    uom: row.uom,
    active: row.active,
    barcode: row.barcode,
    attributes: toRecord(row.attributes_json) ?? {}
  };
}
