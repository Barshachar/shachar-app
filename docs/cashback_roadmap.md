# Cashback & Bitcoin — Roadmap

Status of the customer cashback program and the optional path to converting
balances to Bitcoin. The guiding principle: **Bitcoin is just one redemption
channel on top of a generic cashback ledger.** Build and ship the cashback
foundation first; the BTC path is gated behind a regulatory decision.

## Done (PR #4 + follow-ups)

- **Supabase ledger** — `cashback_ledger` (append-only, ILS), `cashback_balances`
  view (`security_invoker`), customer read-only RLS, admin/service-role writes.
- **Award path** — `rpc_award_order_cashback` (idempotent) + trigger on order
  `delivered`. Hardened so only trusted (service/admin/vendor) transitions award,
  and the RPC is `service_role`-only with a delivered-status guard.
- **Config + redeem** — `cashback_config` (per-company / global rate, max balance,
  expiry days), rate-from-config in the award, and `rpc_redeem_cashback`
  (tenant-scoped, balance-checked, advisory-locked).
- **Flutter** — `cashback` feature (domain/data/presentation) mirroring
  `business_credit`, route `/finance/cashback`, customer-home entry, he/en
  strings, widget test. BTC equivalent + convert CTA gated behind the
  `cashback_btc` feature flag (off by default).
- **Edge function** — `cashback_convert_btc` stub returning 501 until
  `CASHBACK_BTC_ENABLED`, with validation + Deno tests.
- **Expiry** — `rpc_expire_cashback` (patch 025): FIFO lot accounting, idempotent,
  `service_role`-only, with a regression test. Still needs a scheduler to invoke it.

## Phase 0 — close out CI (operational)

- Enable repo variables `RUN_FLUTTER_CI=1` and `RUN_EDGE_TESTS=1` so the Flutter
  widget test and the Deno/RLS suites actually run in CI (currently skipped).
- Run patch `023` + `024` + seed + `rls_regressions.sql` against a real DB once.

## Phase 1 — complete the cashback foundation (highest value, no BTC risk)

1. **Wire the real Supabase repo** — the Flutter app currently defaults to the
   in-memory fake; switch `cashbackRepositoryProvider` to
   `SupabaseCashbackRepository` in the authenticated flow.
2. **Redeem in checkout UI** — surface the `rpc_redeem_cashback` capability
   (already in the repo layer) in the Flutter cart/checkout, applying a `redeem`
   row against the order total.
3. **Admin screen** — view/adjust balances (`adjust` entries) and report total
   outstanding cashback liability.
4. **Notifications** — "you earned ₪X cashback" after delivery, via the existing
   `notifications` table.
5. **Expiry sweep** — ✅ logic implemented in `rpc_expire_cashback` (patch 025).
   Remaining: schedule it (pg_cron or an Edge Function cron) to run daily.

## Phase 2 — Web PWA parity

- Customer cashback dashboard in Next.js (balance + activity) — none today.
- Redeem integration in `CheckoutView` (analogous to the Cardcom flow).

## Phase 3 — Bitcoin decision (the real gate — not technical)

Before any further BTC code:

1. **Legal + tax review (Israel)** — VAT on cashback, capital-gains on
   conversion, reporting duties, AML/KYC, and whether this requires a
   financial-asset-service-provider license.
2. **Model decision** — notional (display only) vs. real withdrawal. Recommended
   start: a **regulated provider that settles to fiat immediately** (Bits of Gold
   / Coinbase), so we hold no keys and bear no volatility.
3. **Provider selection** — fees, KYC, API, Israel coverage.

## Phase 4 — implement BTC conversion (only after Phase 3 clears)

- Replace the `cashback_convert_btc` stub with a real provider integration behind
  `CASHBACK_BTC_ENABLED`.
- Live rate in `BtcRateRepository` (provider/CoinGecko) instead of the fake.
- In-app KYC, a conversion confirmation screen (rate + fee), and a `redeem` row
  to the ledger; track conversion status, failures, and refunds.

## Cross-cutting

- **Security** — keep the PR #4 line: all ledger writes go through controlled
  RPC / service-role only; audit-log every movement.
- **Testing** — keep the CI gates on permanently; add earn→redeem integration
  tests.
- **Language/UX** — keep "convert via a regulated provider", not "Bitcoin that's
  yours", while the model is notional.

## Recommended sequencing

Phase 1 delivers most of the value with almost no risk. Ship cashback (earn +
redeem) **before** entering the Bitcoin track, whose gate is Phase 3 (regulation).
