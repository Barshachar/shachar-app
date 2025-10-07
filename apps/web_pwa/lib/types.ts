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

export type ProductVariant = {
  id: string;
  product_id: string;
  name: string;
  sku: string | null;
  price_cents: number;
  currency: string;
  barcode: string | null;
  variant_prices?: {
    price_group: string;
    price_cents: number;
  }[] | null;
};

export type Product = {
  id: string;
  name: string;
  slug: string;
  sku: string | null;
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
