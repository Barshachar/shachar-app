import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:state_notifier/state_notifier.dart';
import 'package:flutter/foundation.dart';

import 'package:ashachar_marketplace/src/features/rfq/data/rfq_repository.dart';
import 'package:ashachar_marketplace/src/features/rfq/domain/rfq_models.dart';

final rfqRepositoryProvider = Provider<RfqRepository>((ref) {
  final repository = FakeRfqRepository();
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
});

final rfqDraftControllerProvider =
    legacy.StateNotifierProvider<RfqDraftController, RfqDraftState>((ref) {
  final repository = ref.watch(rfqRepositoryProvider);
  return RfqDraftController(repository: repository);
});

final rfqQuotesProvider =
    StreamProvider.autoDispose.family<List<Quote>, String>((ref, rfqId) {
  final repository = ref.watch(rfqRepositoryProvider);
  return repository.watchQuotes(rfqId);
});

@immutable
class RfqDraftLine {
  const RfqDraftLine({
    this.productId = '',
    this.sku = '',
    this.uom = 'unit',
    this.quantity = 1,
    this.targetUnitPrice,
  });

  final String productId;
  final String sku;
  final String uom;
  final int quantity;
  final double? targetUnitPrice;

  RfqDraftLine copyWith({
    String? productId,
    String? sku,
    String? uom,
    int? quantity,
    double? targetUnitPrice,
  }) {
    return RfqDraftLine(
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      uom: uom ?? this.uom,
      quantity: quantity ?? this.quantity,
      targetUnitPrice: targetUnitPrice ?? this.targetUnitPrice,
    );
  }
}

@immutable
class RfqDraftState {
  const RfqDraftState({
    this.isActive = false,
    this.lines = const <RfqDraftLine>[],
    this.requestedDate,
    this.targetCurrency = 'USD',
    this.notes = '',
    this.submission = const AsyncData<RfqRequest?>(null),
    this.lastSubmitted,
  });

  final bool isActive;
  final List<RfqDraftLine> lines;
  final DateTime? requestedDate;
  final String targetCurrency;
  final String notes;
  final AsyncValue<RfqRequest?> submission;
  final RfqRequest? lastSubmitted;

  bool get canSubmit {
    if (!isActive || lines.isEmpty) return false;
    if (requestedDate == null) return false;
    return lines.every((line) =>
        line.productId.isNotEmpty && line.sku.isNotEmpty && line.quantity > 0);
  }

  RfqDraftState copyWith({
    bool? isActive,
    List<RfqDraftLine>? lines,
    DateTime? Function()? requestedDate,
    String? targetCurrency,
    String? notes,
    AsyncValue<RfqRequest?>? submission,
    RfqRequest? Function()? lastSubmitted,
  }) {
    return RfqDraftState(
      isActive: isActive ?? this.isActive,
      lines: lines ?? this.lines,
      requestedDate:
          requestedDate != null ? requestedDate() : this.requestedDate,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      notes: notes ?? this.notes,
      submission: submission ?? this.submission,
      lastSubmitted:
          lastSubmitted != null ? lastSubmitted() : this.lastSubmitted,
    );
  }
}

class RfqDraftController extends StateNotifier<RfqDraftState> {
  RfqDraftController({required this.repository}) : super(const RfqDraftState());

  final RfqRepository repository;
  static const String _buyerId = 'buyer-demo';

  void startNewDraft() {
    final DateTime defaultDate = DateTime.now().add(const Duration(days: 7));
    state = state.copyWith(
      isActive: true,
      lines: List<RfqDraftLine>.unmodifiable(
        const <RfqDraftLine>[RfqDraftLine()],
      ),
      requestedDate: () => defaultDate,
      notes: '',
      submission: const AsyncData<RfqRequest?>(null),
      lastSubmitted: () => null,
    );
  }

  void addLine() {
    final List<RfqDraftLine> updated = List<RfqDraftLine>.from(state.lines)
      ..add(const RfqDraftLine());
    state = state.copyWith(
      lines: List<RfqDraftLine>.unmodifiable(updated),
    );
  }

  void updateLine(int index, RfqDraftLine line) {
    if (index < 0 || index >= state.lines.length) return;
    final List<RfqDraftLine> updated = List<RfqDraftLine>.from(state.lines);
    updated[index] = line;
    state = state.copyWith(
      lines: List<RfqDraftLine>.unmodifiable(updated),
    );
  }

  void removeLine(int index) {
    if (index < 0 || index >= state.lines.length) return;
    final List<RfqDraftLine> updated = List<RfqDraftLine>.from(state.lines)
      ..removeAt(index);
    state = state.copyWith(
      lines: List<RfqDraftLine>.unmodifiable(updated),
    );
  }

  void updateNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void updateCurrency(String value) {
    state = state.copyWith(targetCurrency: value);
  }

  void updateRequestedDate(DateTime? value) {
    state = state.copyWith(requestedDate: () => value);
  }

  Future<void> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(
        submission: AsyncError<RfqRequest?>(
          Exception('rfq.validation'),
          StackTrace.current,
        ),
      );
      return;
    }
    state = state.copyWith(submission: const AsyncLoading<RfqRequest?>());
    try {
      final RfqRequest request = await repository.create(
        buyerId: _buyerId,
        lines: state.lines
            .map((RfqDraftLine draft) => RfqLine(
                  productId: draft.productId,
                  sku: draft.sku,
                  uom: draft.uom,
                  quantity: draft.quantity,
                  targetUnitPrice: draft.targetUnitPrice,
                ))
            .toList(growable: false),
        notes: state.notes.isEmpty ? null : state.notes,
        targetCurrency: state.targetCurrency,
        requestedDeliveryDate: state.requestedDate!,
      );
      state = state.copyWith(
        submission: AsyncData<RfqRequest?>(request),
        lastSubmitted: () => request,
        isActive: true,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        submission: AsyncError<RfqRequest?>(error, stackTrace),
      );
    }
  }
}
