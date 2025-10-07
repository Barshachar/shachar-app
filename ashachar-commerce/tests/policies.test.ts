import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const currentDir = dirname(fileURLToPath(import.meta.url));
const sql = readFileSync(resolve(currentDir, '../supabase/policies.sql'), 'utf8');

describe('RLS policies', () => {
  it('enables row level security on carts', () => {
    expect(sql).toContain('alter table public.carts enable row level security');
  });

  it('provides public read access to products', () => {
    expect(sql).toContain('Public read products');
  });
});
