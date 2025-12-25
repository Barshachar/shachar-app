import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromRow parses approval request payloads', () {
    const String orderId = 'ORDER-1';
    final DateTime sentAt = DateTime.parse('2024-03-01T10:00:00Z');
    final DateTime reviewedAt = DateTime.parse('2024-03-02T12:30:00Z');

    final OrderApprovalState state = OrderApprovalState.fromRow(
      orderId: orderId,
      row: <String, dynamic>{
        'status': 'approved',
        'notes': 'Looks good',
        'created_at': sentAt.toIso8601String(),
        'reviewed_at': reviewedAt.toIso8601String(),
      },
    );

    expect(state.orderId, orderId);
    expect(state.requiresApproval, isTrue);
    expect(state.stage, OrderApprovalStage.approved);
    expect(state.note, 'Looks good');
    expect(state.sentAt, sentAt.toUtc());
    expect(state.resolvedAt, reviewedAt.toUtc());
  });
}
