import 'package:equatable/equatable.dart';

/// A single company's cashback balance, for the admin overview.
class AdminCashbackRow extends Equatable {
  const AdminCashbackRow({
    required this.companyId,
    required this.companyName,
    required this.balanceIls,
  });

  final String companyId;
  final String companyName;
  final double balanceIls;

  @override
  List<Object?> get props => <Object?>[companyId, companyName, balanceIls];
}

/// Reads the cross-company cashback overview and applies manual adjustments.
abstract class AdminCashbackRepository {
  Future<List<AdminCashbackRow>> fetchOverview();

  /// Apply a manual adjustment (positive credits, negative debits) to a
  /// company's cashback. The server enforces admin-only access.
  Future<void> adjust({
    required String companyId,
    required double amountIls,
    String? note,
  });
}
