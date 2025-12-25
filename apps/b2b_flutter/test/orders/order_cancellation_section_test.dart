import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/orders/data/supabase_order_cancellation_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_cancellation.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_cancellation_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/order_cancellation_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_harness.dart';

void main() {
  testWidgets('cancel button renders for cancellable orders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      makeTestApp(
        const Scaffold(
          body: OrderCancellationSection(
            orderId: 'order-1',
            status: 'placed',
          ),
        ),
        overrides: [
          orderCancellationRepositoryProvider.overrideWithValue(
            _FakeOrderCancellationRepository(),
          ),
        ],
        extraDelegates: const [MarketplaceLocalizations.delegate],
        locale: const Locale('en'),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('order_detail_cancel_btn')),
      findsOneWidget,
    );
  });
}

class _FakeOrderCancellationRepository implements OrderCancellationRepository {
  @override
  Future<OrderCancellationSubmission> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    return const OrderCancellationSubmission(queued: true);
  }
}
