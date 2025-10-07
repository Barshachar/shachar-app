import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/features/inventory/domain/putaway_map_view.dart';
import 'package:ashachar_marketplace/src/features/inventory/domain/warehouse_model.dart';
import 'package:ashachar_marketplace/src/features/inventory/presentation/putaway_map_controller.dart';

class PutawayMapPage extends ConsumerWidget {
  const PutawayMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Warehouse>> warehousesAsync =
        ref.watch(availableWarehousesProvider);
    final AsyncValue<PutawayMapView?> mapAsync = ref.watch(putawayMapProvider);
    final String? selectedWarehouseId = ref.watch(selectedWarehouseIdProvider);
    final String? selectedZoneId = ref.watch(selectedZoneIdProvider);
    final String? aisleFilter = ref.watch(selectedAisleFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Putaway Map'),
        backgroundColor: AColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ASpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              warehousesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (Object error, StackTrace stackTrace) => _ErrorBanner(
                  message: 'Unable to load warehouses: $error',
                ),
                data: (List<Warehouse> warehouses) {
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedWarehouseId ??
                              (warehouses.isNotEmpty
                                  ? warehouses.first.id
                                  : null),
                          decoration: _inputDecoration('Warehouse'),
                          items: warehouses
                              .map(
                                (Warehouse warehouse) => DropdownMenuItem(
                                  value: warehouse.id,
                                  child: Text(warehouse.name),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (String? value) {
                            ref
                                .read(selectedWarehouseIdProvider.notifier)
                                .state = value;
                            ref.read(selectedZoneIdProvider.notifier).state =
                                null;
                            ref
                                .read(selectedAisleFilterProvider.notifier)
                                .state = null;
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: ASpacing.lg),
              mapAsync.when(
                loading: () => const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (Object error, StackTrace stackTrace) => Expanded(
                  child: _ErrorBanner(
                    message: 'Unable to load map: $error',
                  ),
                ),
                data: (PutawayMapView? view) {
                  if (view == null) {
                    return const Expanded(
                      child:
                          Center(child: Text('Select a warehouse to view map')),
                    );
                  }
                  final List<WarehouseZone> zones = view.zones;
                  final String? zoneId = selectedZoneId ??
                      (zones.isNotEmpty ? zones.first.id : null);
                  final List<WarehouseBin> zoneBins =
                      zoneId == null ? const [] : view.binsForZone(zoneId);
                  final List<String> aisles = zoneBins
                      .map((WarehouseBin bin) => bin.aisle)
                      .toSet()
                      .toList()
                    ..sort();
                  final List<String> columns = zoneBins
                      .map((WarehouseBin bin) => bin.bin)
                      .toSet()
                      .toList()
                    ..sort((String a, String b) =>
                        (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: ASpacing.lg,
                          runSpacing: ASpacing.md,
                          children: [
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<String>(
                                value: zoneId,
                                decoration: _inputDecoration('Zone'),
                                items: zones
                                    .map(
                                      (WarehouseZone zone) => DropdownMenuItem(
                                        value: zone.id,
                                        child: Text(zone.name),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: (String? value) {
                                  ref
                                      .read(selectedZoneIdProvider.notifier)
                                      .state = value;
                                  ref
                                      .read(
                                          selectedAisleFilterProvider.notifier)
                                      .state = null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<String>(
                                value: aisleFilter,
                                decoration: _inputDecoration('Aisle / Bin'),
                                items: <DropdownMenuItem<String>>[
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All aisles'),
                                  ),
                                  ...aisles.map(
                                    (String aisle) => DropdownMenuItem(
                                      value: aisle,
                                      child: Text('Aisle $aisle'),
                                    ),
                                  ),
                                ],
                                onChanged: (String? value) {
                                  ref
                                      .read(
                                          selectedAisleFilterProvider.notifier)
                                      .state = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: ASpacing.lg),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(ASpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _PutawayGrid(
                                  aisles: aisles,
                                  columns: columns,
                                  bins: zoneBins,
                                  aisleFilter: aisleFilter,
                                ),
                                const SizedBox(height: ASpacing.lg),
                                _Legend(),
                                const SizedBox(height: ASpacing.lg),
                                _NearestEmptyBins(view: view),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AColors.primary,
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Putaway started for worker'),
                                            ),
                                          );
                                        },
                                        child: const Text('Start Putaway'),
                                      ),
                                    ),
                                    const SizedBox(width: ASpacing.md),
                                    Expanded(
                                      child: FilledButton.tonal(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Task completed'),
                                            ),
                                          );
                                        },
                                        child: const Text('Complete'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

class _PutawayGrid extends StatelessWidget {
  const _PutawayGrid({
    required this.aisles,
    required this.columns,
    required this.bins,
    required this.aisleFilter,
  });

  final List<String> aisles;
  final List<String> columns;
  final List<WarehouseBin> bins;
  final String? aisleFilter;

  Color _colorForFill(WarehouseBinFill fill) {
    switch (fill) {
      case WarehouseBinFill.empty:
        return const Color(0xFF34D399);
      case WarehouseBinFill.partial:
        return const Color(0xFF22D3EE);
      case WarehouseBinFill.full:
        return const Color(0xFFEE4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, WarehouseBin>> matrix =
        <String, Map<String, WarehouseBin>>{};
    for (final WarehouseBin bin in bins) {
      matrix.putIfAbsent(bin.aisle, () => <String, WarehouseBin>{})[bin.bin] =
          bin;
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 40),
                ...columns.map(
                  (String column) => Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(column, style: ATypography.bodySm),
                  ),
                ),
              ],
            ),
            ...aisles
                .where((String aisle) =>
                    aisleFilter == null || aisleFilter == aisle)
                .map(
              (String aisle) {
                return Row(
                  children: [
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(aisle, style: ATypography.bodySm),
                    ),
                    ...columns.map(
                      (String column) {
                        final WarehouseBin? bin = matrix[aisle]?[column];
                        final Color color = bin == null
                            ? AColors.neutral200
                            : _colorForFill(bin.fillState);
                        return Container(
                          margin: const EdgeInsets.all(4),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget legend(String label, Color color) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: ASpacing.xs),
          Text(label, style: ATypography.bodySm),
        ],
      );
    }

    return Wrap(
      spacing: ASpacing.lg,
      children: [
        legend('Empty', const Color(0xFF34D399)),
        legend('Partially filled', const Color(0xFF22D3EE)),
        legend('Fully occupied', const Color(0xFFEE4444)),
      ],
    );
  }
}

class _NearestEmptyBins extends StatelessWidget {
  const _NearestEmptyBins({required this.view});

  final PutawayMapView view;

  @override
  Widget build(BuildContext context) {
    final List<WarehouseBin> suggestions = view.nearestEmptyBins();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearest Empty Bins',
          style: ATypography.titleSm,
        ),
        const SizedBox(height: ASpacing.sm),
        if (suggestions.isEmpty)
          Text(
            'No empty bins available',
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
          )
        else
          ...suggestions.map(
            (WarehouseBin bin) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.location_pin, color: AColors.primary),
              title: Text('Aisle ${bin.aisle} / Bin ${bin.bin}'),
              trailing: FilledButton.tonal(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Suggestion assigned to Aisle ${bin.aisle} Bin ${bin.bin}',
                      ),
                    ),
                  );
                },
                child: const Text('Assign Suggestion'),
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ASpacing.lg),
      decoration: BoxDecoration(
        color: AColors.dangerSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AColors.dangerBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AColors.danger),
          const SizedBox(width: ASpacing.md),
          Expanded(
            child: Text(
              message,
              style: ATypography.bodySm.copyWith(color: AColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
