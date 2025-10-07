# ADR 004 – Admin Console in Flutter Web

**Status**: Accepted

## Context

Phase-1 replaces the original React admin with a Flutter Web experience sharing code with the mobile app.

## Decision

- Build admin dashboards under `/app/lib/src/features/admin` using responsive layouts.
- Use the same Riverpod providers and repositories as mobile for catalog, price lists, and reporting.
- Treat admin routing as part of the shared `go_router` configuration to keep deep-links consistent.

## Consequences

- Reduces duplicated logic across clients and ensures identical validation rules.
- Requires careful theming and responsiveness testing (desktop breakpoints) but simplifies localization and offline support.
