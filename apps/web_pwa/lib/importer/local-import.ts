import type { Category, Product, ProductVariant } from '@/lib/types';

export type CsvRecord = {
  name: string;
  slug: string;
  sku: string;
  brand: string;
  category_slug: string;
  price_cents: number;
  primary_image_url: string;
  description_html: string;
};

export type CsvParseError = {
  line: number;
  message: string;
  rowPreview?: string;
};

export type CsvParseResult = {
  records: CsvRecord[];
  errors: CsvParseError[];
  totalRows: number;
};

export type ImportSummary = {
  categories: { added: number; updated: number; skipped: number };
  products: { added: number; updated: number; skipped: number };
  variants: { added: number; updated: number; skipped: number };
};

const CSV_SPLIT_REGEX = /,(?=(?:[^"]*"[^"]*")*[^"]*$)/;

const CANONICAL_FIELDS: (keyof CsvRecord)[] = [
  'name',
  'slug',
  'sku',
  'brand',
  'category_slug',
  'price_cents',
  'primary_image_url',
  'description_html'
];

type SupplierMappedField = Exclude<keyof CsvRecord, 'price_cents'> | 'price_shekel';

const SUPPLIER_HEADER_MAP: Record<string, SupplierMappedField> = {
  'שם מוצר': 'name',
  'מקט': 'sku',
  'מותג': 'brand',
  'קטגוריה': 'category_slug',
  'מחיר (₪)': 'price_shekel',
  'תמונה': 'primary_image_url',
  'תיאור': 'description_html'
};

const HEBREW_TRANSLITERATION: Record<string, string> = {
  א: 'a',
  ב: 'b',
  ג: 'g',
  ד: 'd',
  ה: 'h',
  ו: 'v',
  ז: 'z',
  ח: 'h',
  ט: 't',
  י: 'y',
  כ: 'k',
  ך: 'k',
  ל: 'l',
  מ: 'm',
  ם: 'm',
  נ: 'n',
  ן: 'n',
  ס: 's',
  ע: 'a',
  פ: 'p',
  ף: 'p',
  צ: 'tz',
  ץ: 'tz',
  ק: 'k',
  ר: 'r',
  ש: 'sh',
  ת: 't'
};

function parseLine(line: string): string[] {
  return line
    .split(CSV_SPLIT_REGEX)
    .map((value) => value.trim().replace(/^"|"$/g, '').replace(/""/g, '"'));
}

function slugify(value: string): string {
  const trimmed = value.trim();
  if (!trimmed) {
    return '';
  }

  const transliterated = trimmed
    .normalize('NFKD')
    .replace(/[\u0590-\u05FF]/g, (char) => {
      const mapped = HEBREW_TRANSLITERATION[char as keyof typeof HEBREW_TRANSLITERATION];
      if (mapped) {
        return mapped;
      }
      const lower = char.toLowerCase();
      return HEBREW_TRANSLITERATION[lower as keyof typeof HEBREW_TRANSLITERATION] ?? '';
    })
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/&/g, ' and ');

  return transliterated
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/-{2,}/g, '-')
    .replace(/^-|-$/g, '');
}

function parseShekelPrice(raw: string): number | null {
  const trimmed = raw.trim();
  if (!trimmed) {
    return null;
  }
  let normalized = trimmed.replace(/[₪\s]/g, '');
  const hasComma = normalized.includes(',');
  const hasDot = normalized.includes('.');
  if (hasComma && hasDot) {
    if (normalized.lastIndexOf(',') > normalized.lastIndexOf('.')) {
      normalized = normalized.replace(/\./g, '').replace(',', '.');
    } else {
      normalized = normalized.replace(/,/g, '');
    }
  } else if (hasComma) {
    normalized = normalized.replace(/,/g, '.');
  }
  const value = Number.parseFloat(normalized);
  if (Number.isNaN(value)) {
    return null;
  }
  return Math.round(value * 100);
}

type CanonicalHeader = {
  mode: 'canonical';
  indexes: Record<keyof CsvRecord, number>;
};

type SupplierHeader = {
  mode: 'supplier';
  indexes: {
    name: number;
    sku: number;
    brand: number;
    category_slug: number;
    price: number;
    primary_image_url: number;
    description_html: number;
    slug?: number;
  };
};

type HeaderMapping = CanonicalHeader | SupplierHeader;

function detectHeader(headerCells: string[]): HeaderMapping {
  const normalized = headerCells.map((cell) => cell.trim());
  const lower = normalized.map((cell) => cell.toLowerCase());

  const canonicalIndexes: Partial<Record<keyof CsvRecord, number>> = {};
  for (const key of CANONICAL_FIELDS) {
    const index = lower.indexOf(key);
    if (index >= 0) {
      canonicalIndexes[key] = index;
    }
  }
  if (CANONICAL_FIELDS.every((key) => canonicalIndexes[key] !== undefined)) {
    return {
      mode: 'canonical',
      indexes: canonicalIndexes as Record<keyof CsvRecord, number>
    };
  }

  const supplierIndexes: SupplierHeader['indexes'] = {
    name: -1,
    sku: -1,
    brand: -1,
    category_slug: -1,
    price: -1,
    primary_image_url: -1,
    description_html: -1
  };

  for (let i = 0; i < normalized.length; i += 1) {
    const value = normalized[i];
    const mapped = SUPPLIER_HEADER_MAP[value];
    if (mapped === 'price_shekel') {
      supplierIndexes.price = i;
    } else if (mapped) {
      supplierIndexes[mapped] = i;
    }
    if (!mapped && lower[i] === 'slug') {
      supplierIndexes.slug = i;
    }
  }

  const supplierMissing = Object.entries(supplierIndexes)
    .filter(([key, index]) => key !== 'slug' && index < 0)
    .map(([key]) => key);

  if (!supplierMissing.length) {
    return {
      mode: 'supplier',
      indexes: supplierIndexes
    };
  }

  const canonicalList = CANONICAL_FIELDS.join(', ');
  const supplierList = Object.keys(SUPPLIER_HEADER_MAP).join(', ');
  throw new Error(`Unsupported CSV headers. Expected canonical columns (${canonicalList}) or supplier columns (${supplierList}).`);
}

export function parseCsv(content: string): CsvParseResult {
  const lines = content.split(/\r?\n/).filter((line) => line.trim().length > 0);
  if (!lines.length) {
    return { records: [], errors: [], totalRows: 0 };
  }

  const headerCells = parseLine(lines[0]);
  const mapping = detectHeader(headerCells);
  const records: CsvRecord[] = [];
  const errors: CsvParseError[] = [];

  for (let i = 1; i < lines.length; i += 1) {
    const rawValues = parseLine(lines[i]);
    if (rawValues.length === 0 || rawValues.every((value) => value.trim() === '')) {
      continue;
    }
    const lineNumber = i + 1;
    const rowErrors: string[] = [];

    if (mapping.mode === 'canonical') {
      const get = (key: keyof CsvRecord) => rawValues[mapping.indexes[key]] ?? '';
      const name = get('name').trim();
      const slugSource = get('slug').trim();
      const sku = get('sku').trim();
      const brand = get('brand').trim();
      const categoryRaw = get('category_slug').trim();
      const priceRaw = get('price_cents').trim();
      const primaryImage = get('primary_image_url').trim();
      const description = get('description_html').trim();

      const slug = slugify(slugSource || name);
      const categorySlug = slugify(categoryRaw);
      const priceValue = Number.parseInt(priceRaw, 10);

      if (!name) rowErrors.push('שם מוצר חסר בעמודה name');
      if (!slug) rowErrors.push('slug ריק או לא תקין');
      if (!sku) rowErrors.push('SKU חסר בעמודה sku');
      if (!brand) rowErrors.push('מותג חסר בעמודה brand');
      if (!categorySlug) rowErrors.push('category_slug ריק או לא תקין');
      if (Number.isNaN(priceValue)) rowErrors.push('price_cents אינו מספר תקין');

      if (rowErrors.length) {
        errors.push({ line: lineNumber, message: rowErrors.join('; '), rowPreview: name || slugSource || sku });
        continue;
      }

      records.push({
        name,
        slug,
        sku,
        brand,
        category_slug: categorySlug,
        price_cents: priceValue,
        primary_image_url: primaryImage,
        description_html: description
      });
      continue;
    }

    const name = (rawValues[mapping.indexes.name] ?? '').trim();
    const slugCandidate = mapping.indexes.slug !== undefined ? (rawValues[mapping.indexes.slug] ?? '').trim() : '';
    const sku = (rawValues[mapping.indexes.sku] ?? '').trim();
    const brand = (rawValues[mapping.indexes.brand] ?? '').trim();
    const categoryRaw = (rawValues[mapping.indexes.category_slug] ?? '').trim();
    const priceRaw = (rawValues[mapping.indexes.price] ?? '').trim();
    const primaryImage = (rawValues[mapping.indexes.primary_image_url] ?? '').trim();
    const description = (rawValues[mapping.indexes.description_html] ?? '').trim();

    const slug = slugify(slugCandidate || name);
    const categorySlug = slugify(categoryRaw);
    const priceValue = parseShekelPrice(priceRaw);

    if (!name) rowErrors.push('שם מוצר חסר');
    if (!slug) rowErrors.push('לא ניתן להפיק slug משם המוצר');
    if (!sku) rowErrors.push('מקט חסר');
    if (!brand) rowErrors.push('מותג חסר');
    if (!categorySlug) rowErrors.push('קטגוריה ריקה או לא תקינה');
    if (priceValue === null) rowErrors.push('מחיר אינו מספר חוקי בשקלים');

    if (rowErrors.length) {
      errors.push({ line: lineNumber, message: rowErrors.join('; '), rowPreview: name || sku });
      continue;
    }

    const priceCents = priceValue as number;

    records.push({
      name,
      slug,
      sku,
      brand,
      category_slug: categorySlug,
      price_cents: priceCents,
      primary_image_url: primaryImage,
      description_html: description
    });
  }

  return { records, errors, totalRows: lines.length - 1 };
}

function humanizeSlug(slug: string): string {
  return slug
    .split(/[-_]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function vendorSlug(brand: string): string {
  const cleaned = brand.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  return cleaned || 'local-vendor';
}

function ensureCategory(
  slug: string,
  categories: Category[],
  summary: ImportSummary['categories']
): { category: Category; created: boolean } {
  const existing = categories.find((item) => item.slug === slug);
  if (existing) {
    return { category: existing, created: false };
  }
  const category: Category = {
    id: `cat-${slug}`,
    name: humanizeSlug(slug),
    slug,
    image_url: `/categories/${slug}.png`,
    parent_id: null
  };
  categories.push(category);
  summary.added += 1;
  return { category, created: true };
}

function updateCategory(
  category: Category,
  record: CsvRecord,
  summary: ImportSummary['categories'],
  created: boolean
) {
  const expectedName = humanizeSlug(record.category_slug);
  const expectedImage = `/categories/${record.category_slug}.png`;
  let changed = false;
  if (category.name !== expectedName) {
    category.name = expectedName;
    changed = true;
  }
  if (!category.image_url) {
    category.image_url = expectedImage;
    changed = true;
  }
  if (created) {
    return;
  }
  if (changed) {
    summary.updated += 1;
  } else {
    summary.skipped += 1;
  }
}

function upsertProduct(
  record: CsvRecord,
  products: Product[],
  summary: ImportSummary['products']
): Product {
  const productId = `p_${record.slug}`;
  const vendor = vendorSlug(record.brand);
  const existing = products.find((item) => item.slug === record.slug);
  const createdAt = existing?.created_at ?? new Date().toISOString();
  if (!existing) {
    const product: Product = {
      id: productId,
      name: record.name,
      slug: record.slug,
      sku: record.sku,
      brand: record.brand,
      vendor_slug: vendor,
      category_slug: record.category_slug,
      primary_image_url: record.primary_image_url || '/placeholders/p0.png',
      description_html: record.description_html || '<p>ללא תיאור</p>',
      is_active: true,
      created_at: createdAt,
      variants: []
    };
    products.push(product);
    summary.added += 1;
    return product;
  }

  const fields: (keyof Product)[] = [
    'name',
    'sku',
    'brand',
    'vendor_slug',
    'category_slug',
    'primary_image_url',
    'description_html'
  ];
  let changed = false;
  const updates: Partial<Product> = {
    name: record.name,
    sku: record.sku,
    brand: record.brand,
    vendor_slug: vendor,
    category_slug: record.category_slug,
    primary_image_url: record.primary_image_url || '/placeholders/p0.png',
    description_html: record.description_html || existing.description_html,
    is_active: true,
    created_at: createdAt
  };
  for (const key of fields) {
    if ((existing as any)[key] !== (updates as any)[key]) {
      (existing as any)[key] = (updates as any)[key];
      changed = true;
    }
  }
  if (existing.created_at !== createdAt) {
    existing.created_at = createdAt;
  }
  if (!existing.is_active) {
    existing.is_active = true;
    changed = true;
  }
  if (changed) {
    summary.updated += 1;
  } else {
    summary.skipped += 1;
  }
  return existing;
}

function upsertVariant(
  record: CsvRecord,
  product: Product,
  variants: ProductVariant[],
  summary: ImportSummary['variants']
) {
  const variantId = `v_${record.slug}_default`;
  const existing = variants.find((item) => item.id === variantId);
  if (!existing) {
    const variant: ProductVariant = {
      id: variantId,
      product_id: product.id,
      name: 'ברירת מחדל',
      sku: `${record.sku || record.slug}-DEF`,
      price_cents: record.price_cents,
      currency: 'ILS',
      barcode: null,
      variant_prices: [
        {
          price_group: 'installer',
          price_cents: Math.round(record.price_cents * 0.9)
        }
      ]
    };
    variants.push(variant);
    summary.added += 1;
    return;
  }
  let changed = false;
  if (existing.product_id !== product.id) {
    existing.product_id = product.id;
    changed = true;
  }
  const expectedSku = `${record.sku || record.slug}-DEF`;
  if (existing.sku !== expectedSku) {
    existing.sku = expectedSku;
    changed = true;
  }
  if (existing.price_cents !== record.price_cents) {
    existing.price_cents = record.price_cents;
    changed = true;
  }
  if (!existing.variant_prices || !existing.variant_prices.length) {
    existing.variant_prices = [
      {
        price_group: 'installer',
        price_cents: Math.round(record.price_cents * 0.9)
      }
    ];
    changed = true;
  }
  if (changed) {
    summary.updated += 1;
  } else {
    summary.skipped += 1;
  }
}

export function upsertCatalog(
  records: CsvRecord[],
  categories: Category[],
  products: Product[],
  variants: ProductVariant[]
): { categories: Category[]; products: Product[]; variants: ProductVariant[]; summary: ImportSummary } {
  const summary: ImportSummary = {
    categories: { added: 0, updated: 0, skipped: 0 },
    products: { added: 0, updated: 0, skipped: 0 },
    variants: { added: 0, updated: 0, skipped: 0 }
  };

  const categoriesCopy = [...categories];
  const productsCopy = [...products];
  const variantsCopy = [...variants];

  for (const record of records) {
    const { category, created } = ensureCategory(record.category_slug, categoriesCopy, summary.categories);
    updateCategory(category, record, summary.categories, created);
    const product = upsertProduct(record, productsCopy, summary.products);
    product.category_slug = record.category_slug;
    upsertVariant(record, product, variantsCopy, summary.variants);
  }

  return {
    categories: categoriesCopy,
    products: productsCopy,
    variants: variantsCopy,
    summary
  };
}
