import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

type InventoryRow = {
  variant_id: string;
  qty: number;
  low_stock_threshold: number;
};

type AdminCompanyRow = { id: string };

type CompanyUserRow = {
  user_id: string;
  company_id: string;
};

serve(async (_req) => {
  const supabase = getServiceClient();

  const { data: inventory, error: inventoryError } = await supabase
    .from('inventory')
    .select('variant_id, quantity, low_stock_threshold');

  if (inventoryError) {
    return errorResponse(inventoryError.message, 500);
  }

  const items = (inventory ?? []).map((row: any) => ({
    variant_id: row.variant_id,
    qty: Number(row.quantity ?? row.qty ?? 0),
    low_stock_threshold: Number(row.low_stock_threshold ?? 0),
  })) as InventoryRow[];
  const lowStock = items.filter((item) => Number(item.qty) <= Number(item.low_stock_threshold ?? 0));

  if (!lowStock.length) {
    return jsonResponse({ scanned: items.length, low_stock: 0 });
  }

  const { data: adminCompanies, error: adminCompaniesError } = await supabase
    .from('companies')
    .select('id')
    .eq('company_type', 'admin');

  if (adminCompaniesError) {
    return errorResponse(adminCompaniesError.message, 500);
  }

  const adminCompanyIds = (adminCompanies ?? []).map((row) => (row as AdminCompanyRow).id);

  let adminRecipients: CompanyUserRow[] = [];
  if (adminCompanyIds.length > 0) {
    const { data: admins, error: adminsError } = await supabase
      .from('company_users')
      .select('user_id, company_id')
      .in('company_id', adminCompanyIds)
      .eq('role', 'admin');

    if (adminsError) {
      return errorResponse(adminsError.message, 500);
    }

    adminRecipients = (admins ?? []) as CompanyUserRow[];
  }

  const variantIds = lowStock.map((item) => item.variant_id);
  const { data: variantVendors, error: variantVendorError } = variantIds.length
    ? await supabase
        .from('product_variants')
        .select('id, products!inner(vendor_company_id)')
        .in('id', variantIds)
    : { data: [], error: null };

  if (variantVendorError) {
    return errorResponse(variantVendorError.message, 500);
  }

  const vendorMap = new Map<string, string>();
  for (const record of (variantVendors ?? []) as Array<{ id: string; products: { vendor_company_id: string } }>) {
    vendorMap.set(record.id, record.products.vendor_company_id);
  }

  const vendorCompanyIds = Array.from(new Set(Array.from(vendorMap.values())));
  const { data: vendorAdminsData, error: vendorAdminsError } = vendorCompanyIds.length
    ? await supabase
        .from('company_users')
        .select('user_id, company_id')
        .in('company_id', vendorCompanyIds)
        .in('role', ['vendor_admin'])
    : { data: [], error: null };

  if (vendorAdminsError) {
    return errorResponse(vendorAdminsError.message, 500);
  }

  const vendorRecipientMap = new Map<string, string[]>();
  for (const record of (vendorAdminsData ?? []) as CompanyUserRow[]) {
    const current = vendorRecipientMap.get(record.company_id) ?? [];
    current.push(record.user_id);
    vendorRecipientMap.set(record.company_id, current);
  }

  for (const record of lowStock) {
    for (const admin of adminRecipients) {
      await supabase.from('notifications').insert({
        user_id: admin.user_id,
        title: 'Low stock alert',
        body: `Variant ${record.variant_id} below threshold`,
        data: record,
      });
    }

    const vendorCompanyId = vendorMap.get(record.variant_id);
    if (vendorCompanyId) {
      for (const vendorUser of vendorRecipientMap.get(vendorCompanyId) ?? []) {
        await supabase.from('notifications').insert({
          user_id: vendorUser,
          title: 'Low stock alert',
          body: `Variant ${record.variant_id} below threshold`,
          data: record,
        });
      }
    }
  }

  return jsonResponse({ scanned: items.length, low_stock: lowStock.length });
});
