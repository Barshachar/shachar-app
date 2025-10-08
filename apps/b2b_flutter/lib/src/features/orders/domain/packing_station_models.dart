import 'package:equatable/equatable.dart';

class PackingStationOrder extends Equatable {
  const PackingStationOrder({
    required this.orderNumber,
    required this.lines,
    required this.boxDimensions,
    required this.weight,
  });

  final String orderNumber;
  final List<PackingStationLine> lines;
  final String boxDimensions;
  final double weight;

  @override
  List<Object> get props => <Object>[orderNumber, lines, boxDimensions, weight];
}

class PackingStationLine extends Equatable {
  const PackingStationLine({
    required this.name,
    required this.quantityOrdered,
    required this.quantityPacked,
    this.symbol,
  });

  final String name;
  final int quantityOrdered;
  final int quantityPacked;
  final String? symbol;

  PackingStationLine copyWith({int? quantityPacked}) => PackingStationLine(
        name: name,
        quantityOrdered: quantityOrdered,
        quantityPacked: quantityPacked ?? this.quantityPacked,
        symbol: symbol,
      );

  @override
  List<Object?> get props =>
      <Object?>[name, quantityOrdered, quantityPacked, symbol];
}
