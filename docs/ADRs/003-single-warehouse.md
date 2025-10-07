# ADR 003 – Single Warehouse (Variant-level Inventory)

**Status**: Accepted

## Context

Phase-1 scope restricts logistics to a single physical warehouse per vendor. Inventory is tracked per variant, no multi-warehouse availability.

## Decision

- Model inventory with `inventory(variant_id, qty, low_stock_threshold)` and no warehouse dimension.
- Edge `low_stock_scanner` alerts use variant thresholds.
- Reserve schema space for later expansion via feature-flag table `returns` and well-typed enums.

## Consequences

- Simplifies inventory joins and pricing logic.
- When warehouses are introduced we will add `warehouse_id` and adapt policies; current code isolates logic in repositories to ease migrations.
