# Autonomous Agent Guidance

This repository was generated for the “א.שחר” B2B multi-vendor marketplace.

Key principles for any agent contributing to this codebase:
- Always preserve tenant isolation enforced by Supabase RLS policies; never bypass via service role keys in client code.
- Respect the Clean Architecture layering in the Flutter app (`core` -> `data` -> `domain` -> `presentation`).
- Maintain parity between database schema, Dart DTOs, and Edge Function contracts; update migrations, documentation, and seeds together.
- Treat admin features as Flutter Web first-class citizens; ensure responsive layouts and RTL coverage across all flows.
- Enforce offline-first primitives: cache, delta-sync, and optimistic queues exactly as defined in docs/offline.md.
- All new features require unit tests, RLS regression tests, and CI validation before merging.

Refer to `docs/` for ERD, RLS matrices, API references, ADRs, and operational runbooks.
