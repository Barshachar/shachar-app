import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/returns/data/supabase_return_request_repository.dart';
import 'package:ashachar_marketplace/src/features/returns/domain/return_request.dart';
import 'package:ashachar_marketplace/src/features/returns/domain/return_request_repository.dart';
import 'package:ashachar_marketplace/src/features/returns/presentation/order_returns_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_harness.dart';

void main() {
  testWidgets('return request button enabled for eligible items',
      (tester) async {
    final ReturnRequestRepository repository = _FakeReturnRequestRepository();
    final OrderItem item = OrderItem(
      id: 'item-1',
      variantId: 'variant-1',
      vendorCompanyId: 'vendor-1',
      qty: 2,
      unitPrice: 10,
      lineTotal: 20,
      productName: 'Product',
      variantSku: 'SKU-1',
    );

    await tester.pumpWidget(
      makeTestApp(
        Scaffold(
          body: SingleChildScrollView(
            child: OrderReturnsSection(
              orderId: 'order-1',
              orderStatus: 'shipped',
              items: [item],
            ),
          ),
        ),
        overrides: [
          returnRequestRepositoryProvider.overrideWithValue(repository),
        ],
        extraDelegates: const [_FakeMarketplaceLocalizationsDelegate()],
      ),
    );

    await tester.pumpAndSettle();

    final Finder buttonFinder =
        find.byKey(const ValueKey('order_return_request_button_item-1'));
    final AButton button = tester.widget(buttonFinder);
    expect(button.onPressed, isNotNull);
  });
}

class _FakeReturnRequestRepository implements ReturnRequestRepository {
  @override
  Future<List<ReturnRequest>> fetchReturnRequests(String orderId) async {
    return const <ReturnRequest>[];
  }

  @override
  Future<ReturnRequestSubmission> submitReturnRequest({
    required String orderId,
    required String orderItemId,
    required double qty,
    String? reason,
  }) async {
    return ReturnRequestSubmission(
      request: ReturnRequest(
        id: 'return-1',
        orderId: orderId,
        orderItemId: orderItemId,
        qty: qty,
        status: 'requested',
        createdAt: DateTime.now(),
        reason: reason,
        createdBy: 'user-1',
      ),
    );
  }
}

class _FakeMarketplaceLocalizations extends MarketplaceLocalizations {
  _FakeMarketplaceLocalizations(super.locale);

  @override
  Future<void> load() async {}

  @override
  String translate(String key) => key;
}

class _FakeMarketplaceLocalizationsDelegate
    extends LocalizationsDelegate<MarketplaceLocalizations> {
  const _FakeMarketplaceLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MarketplaceLocalizations> load(Locale locale) async {
    final localization = _FakeMarketplaceLocalizations(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<MarketplaceLocalizations> old,
  ) =>
      false;
}
