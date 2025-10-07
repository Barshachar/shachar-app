# ADR 002 – Disable Order Approvals in Phase-1

**Status**: Accepted

## Context

The original playbook includes multi-step approvals. For Phase-1 the business agreed to ship without approvals to shorten time-to-value.

## Decision

- Remove approval gating from `rpc_submit_order`, UI flows, and RLS policies.
- Track the historical requirement in documentation so we can reintroduce in later phases.

## Consequences

- Submit button immediately places the order after server-side pricing validation.
- Audit logs preserve submission events; future approvals can hook into the same log stream.
- Simplifies testing (no approval transitions), but we must revisit before enabling higher-risk customers.
