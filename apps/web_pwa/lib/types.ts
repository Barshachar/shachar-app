import type { ProductDto, ProductVariantDto, PriceQuote, OrderDto, OrderItemDto } from '@ashachar/contracts';

export type Vendor = {
  id: string;
  name: string;
  slug: string;
  logo_url: string | null;
};

export type Category = {
  id: string;
  name: string;
  slug: string;
  image_url: string | null;
  parent_id: string | null;
};

type ContractsProduct = Omit<ProductDto, 'vendorCompanyId' | 'categoryId' | 'uom' | 'active' | 'sku'>;
type ContractsVariant = Omit<ProductVariantDto, 'productId' | 'uom' | 'active' | 'sku' | 'attributes'>;

export type ProductVariant = ContractsVariant & {
  productId?: string;
  product_id?: string;
  name: string;
  sku: string | null;
  uom?: string;
  active?: boolean;
  price_cents: number;
  currency: string;
  barcode: string | null;
  attributes?: Record<string, unknown>;
  variant_prices?: {
    price_group: string;
    price_cents: number;
  }[] | null;
};

export type Product = ContractsProduct & {
  vendorCompanyId?: string;
  categoryId?: string | null;
  uom?: string;
  active?: boolean;
  sku: string | null;
  name: string;
  slug: string;
  brand: string | null;
  vendor_slug: string;
  category_slug: string;
  primary_image_url: string | null;
  description_html: string | null;
  is_active: boolean;
  created_at: string | null;
  variants: ProductVariant[];
};

export type CartItem = {
  id: string;
  cart_id: string;
  variant_id: string;
  qty: number;
  variant: ProductVariant;
  product: {
    id: string;
    name: string;
    primary_image_url: string | null;
    vendor_slug: string;
  };
};

export type { PriceQuote, OrderDto, OrderItemDto };
