import 'package:flutter_riverpod/legacy.dart';

import 'package:ashachar_marketplace/src/features/orders/domain/packing_station_models.dart';

final packingStationOrderProvider =
    StateNotifierProvider<PackingStationController, PackingStationOrder>((ref) {
  return PackingStationController(
    const PackingStationOrder(
      orderNumber: '#012345',
      boxDimensions: '18 x 14 x 12 in',
      weight: 7.2,
      lines: <PackingStationLine>[
        PackingStationLine(
          name: 'Paint Brush 1"',
          quantityOrdered: 3,
          quantityPacked: 0,
          symbol: 'brush',
        ),
        PackingStationLine(
          name: 'Bordeaux Paint A',
          quantityOrdered: 1,
          quantityPacked: 1,
          symbol: 'paint',
        ),
        PackingStationLine(
          name: 'Foam Roller Cover',
          quantityOrdered: 7,
          quantityPacked: 7,
          symbol: 'roller',
        ),
      ],
    ),
  );
});

class PackingStationController extends StateNotifier<PackingStationOrder> {
  PackingStationController(super.state);

  void updateLine({required int index, required int quantity}) {
    final List<PackingStationLine> updated = List<PackingStationLine>.from(
      state.lines,
    );
    final PackingStationLine current = updated[index];
    updated[index] = current.copyWith(quantityPacked: quantity);
    state = PackingStationOrder(
      orderNumber: state.orderNumber,
      lines: updated,
      boxDimensions: state.boxDimensions,
      weight: state.weight,
    );
  }
}
