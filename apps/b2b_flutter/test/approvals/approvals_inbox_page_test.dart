import 'package:ashachar_marketplace/src/features/approvals/presentation/approvals_inbox_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApprovalRequest.fromMap maps legacy keys and defaults', () {
    final ApprovalRequest request = ApprovalRequest.fromMap(<String, dynamic>{
      'approval_step_id': 'step-42',
      'order_id': 'order-99',
      'order_number': 'PO-0099',
      'order_total': 1234.5,
      'order_currency': '₪',
      'requested_at': '2025-05-01T09:15:00Z',
      'requester_name': 'Noa Cohen',
      'company_name': 'א.שחר',
      'reason': 'Over budget',
      'status': 'pending_approval',
    });

    expect(request.stepId, 'step-42');
    expect(request.orderId, 'order-99');
    expect(request.orderNumber, 'PO-0099');
    expect(request.total, 1234.5);
    expect(request.currency, '₪');
    expect(request.requestedBy, 'Noa Cohen');
    expect(request.buyerName, 'א.שחר');
    expect(request.note, 'Over budget');
    expect(request.status, 'pending_approval');
  });
}
