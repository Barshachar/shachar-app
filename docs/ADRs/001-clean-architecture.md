# ADR 001 – Clean Architecture with Riverpod

**Status**: Accepted

## Context

Phase-1 mandates Clean Architecture, Riverpod, and `go_router`. The marketplace spans mobile, web, admin flows, and offline-first caches.

## Decision

- Slice the Flutter app into `core`, `features`, `data`, `domain`, and `presentation` layers.
- Manage dependencies via Riverpod providers, using `AsyncNotifier` / `FutureProvider` where asynchronous.
- Keep DTOs (Freezed) in `domain`, repository implementations in `data`, and UI widgets in `presentation`.
- Reuse routers and offline primitives through providers to avoid singleton globals.

## Consequences

- Onboarding new features requires defining DTO + repository + controller before UI.
- Unit testing remains straightforward by mocking providers.
- Boilerplate increases (providers, DTOs) but ensures separation of concerns and easier multi-platform reuse.
