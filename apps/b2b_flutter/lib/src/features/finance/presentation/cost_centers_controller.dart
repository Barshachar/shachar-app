import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:state_notifier/state_notifier.dart';

import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
import 'package:ashachar_marketplace/src/features/finance/data/cost_center_repository.dart';
import 'package:ashachar_marketplace/src/features/finance/domain/cost_center.dart';

enum CostCenterStatusFilter { all, active, requiresApprover, archived }

class CostCenterFilterState {
  const CostCenterFilterState({
    this.businessUnit,
    this.costCenterCode,
    this.searchTerm = '',
    this.status = CostCenterStatusFilter.all,
  });

  final String? businessUnit;
  final String? costCenterCode;
  final String searchTerm;
  final CostCenterStatusFilter status;

  CostCenterFilterState copyWith({
    String? businessUnit,
    bool clearBusinessUnit = false,
    String? costCenterCode,
    bool clearCostCenter = false,
    String? searchTerm,
    CostCenterStatusFilter? status,
  }) {
    return CostCenterFilterState(
      businessUnit:
          clearBusinessUnit ? null : (businessUnit ?? this.businessUnit),
      costCenterCode:
          clearCostCenter ? null : (costCenterCode ?? this.costCenterCode),
      searchTerm: searchTerm ?? this.searchTerm,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CostCenterFilterState &&
        other.businessUnit == businessUnit &&
        other.costCenterCode == costCenterCode &&
        other.searchTerm == searchTerm &&
        other.status == status;
  }

  @override
  int get hashCode =>
      Object.hash(businessUnit, costCenterCode, searchTerm, status);
}

class CostCenterFilterNotifier extends StateNotifier<CostCenterFilterState> {
  CostCenterFilterNotifier() : super(const CostCenterFilterState());

  void setBusinessUnit(String? value) {
    state = state.copyWith(businessUnit: value, clearCostCenter: true);
  }

  void setCostCenterCode(String? value) {
    state = state.copyWith(costCenterCode: value);
  }

  void setStatus(CostCenterStatusFilter status) {
    state = state.copyWith(status: status);
  }

  void setSearchTerm(String value) {
    state = state.copyWith(searchTerm: value);
  }

  void reset() {
    state = const CostCenterFilterState();
  }
}

final costCenterFilterProvider = legacy.StateNotifierProvider.autoDispose<
    CostCenterFilterNotifier, CostCenterFilterState>((ref) {
  return CostCenterFilterNotifier();
});

final costCenterListProvider = legacy.StateNotifierProvider.autoDispose<
    CostCenterListController, AsyncValue<List<CostCenter>>>((ref) {
  return CostCenterListController(ref);
});

class CostCenterListController
    extends StateNotifier<AsyncValue<List<CostCenter>>> {
  CostCenterListController(this._ref)
      : super(const AsyncValue<List<CostCenter>>.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final repository = _ref.read(costCenterRepositoryProvider);
    final profileAsync = _ref.read(userProfileProvider);
    final String? companyId = profileAsync.asData?.value?.companyId;
    try {
      final List<CostCenter> centers =
          await repository.fetchCostCenters(companyId: companyId);
      centers.sort((a, b) => a.code.compareTo(b.code));
      state = AsyncValue<List<CostCenter>>.data(centers);
    } catch (error, stack) {
      state = AsyncValue<List<CostCenter>>.error(error, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue<List<CostCenter>>.loading();
    await _load();
  }

  Future<void> toggleActive({
    required String id,
    required bool active,
  }) async {
    final previous = state.value;
    if (previous == null) {
      return;
    }
    final repository = _ref.read(costCenterRepositoryProvider);
    final List<CostCenter> updated = previous
        .map((CostCenter center) => center.id == id
            ? center.copyWith(
                status: active
                    ? CostCenterStatus.active
                    : CostCenterStatus.archived,
              )
            : center)
        .toList(growable: false);
    state = AsyncValue<List<CostCenter>>.data(updated);
    try {
      await repository.setActive(id, active);
    } catch (error, stack) {
      state = AsyncValue<List<CostCenter>>.data(previous);
      Error.throwWithStackTrace(error, stack);
    }
  }

  Future<void> toggleRequiresApprover({
    required String id,
    required bool requires,
  }) async {
    final previous = state.value;
    if (previous == null) {
      return;
    }
    final repository = _ref.read(costCenterRepositoryProvider);
    final List<CostCenter> updated = previous
        .map((CostCenter center) => center.id == id
            ? center.copyWith(requiresApprover: requires)
            : center)
        .toList(growable: false);
    state = AsyncValue<List<CostCenter>>.data(updated);
    try {
      await repository.setRequiresApprover(id, requires);
    } catch (error, stack) {
      state = AsyncValue<List<CostCenter>>.data(previous);
      Error.throwWithStackTrace(error, stack);
    }
  }
}
