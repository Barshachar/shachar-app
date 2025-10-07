import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const currentDir = dirname(fileURLToPath(import.meta.url));
const sql = readFileSync(
  resolve(currentDir, '../../../supabase/sql/policies.sql'),
  'utf8'
);

describe('RLS policies', () => {
  it('enables row level security on orders table', () => {
    expect(sql).toContain('alter table orders enable row level security;');
  });

  it('defines admin policy for products', () => {
    expect(sql).toContain('create policy products_admin_all on products');
  });
});
