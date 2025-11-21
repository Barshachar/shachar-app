\set ON_ERROR_STOP on

-- Recreate a clean public schema for assertions.
drop schema if exists public cascade;
create schema public;
grant usage on schema public to postgres, anon, authenticated;

\i ../sql/schema.sql
\i ../seed.sql
\i ../sql/policies.sql
\i rls_assertions.sql
