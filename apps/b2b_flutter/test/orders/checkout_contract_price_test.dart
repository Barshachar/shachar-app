import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../fakes/fake_price_service.dart';
import '../test_utils/fake_session_controller.dart';
import '../test_utils/offline_supabase.dart';
import '../test_harness.dart';

import '../quick_order/quick_order_test_utils.dart'
    show FakeCatalogRepository, FakeOrdersRepository;

class _CheckoutOrdersRepository extends FakeOrdersRepository {
  @override
  Future<String> createDraftIfMissing() async => 'order-123';
}

Session _fakeSession() => Session.fromJson(<String, dynamic>{
      'access_token': 'token',
      'token_type': 'bearer',
      'refresh_token': 'refresh',
      'expires_in': 3600,
      'expires_at':
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      'user': <String, dynamic>{
        'id': 'user-id',
        'aud': 'authenticated',
        'email': 'tester@example.com',
        'app_metadata': <String, dynamic>{
          'provider': 'email',
          'providers': <String>['email'],
          'company_id': 'COMP-1',
        },
        'user_metadata': const <String, dynamic>{},
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    })!;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await ensureSupabaseForTests();
  });

  testWidgets('checkout summary shows effective price and contract chip',
      (WidgetTester tester) async {
    const String orderId = 'order-123';
    final CartLine line = CartLine(
      id: 'line-1',
      orderId: orderId,
      variantId: 'VAR-1',
      vendorCompanyId: 'vendor-1',
      qty: 3,
      unitPrice: 25,
      lineTotal: 75,
      productName: 'Demo product',
    );

    await tester.pumpWidget(
      makeTestApp(
        const CheckoutPage(orderId: orderId),
        locale: const Locale('en'),
        overrides: [
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
          ordersRepositoryProvider
              .overrideWithValue(_CheckoutOrdersRepository()),
          cartControllerProvider.overrideWith((ref) {
            final controller = CartController(
              ref,
              ref.watch(ordersRepositoryProvider),
              catalogRepository: ref.watch(catalogRepositoryProvider),
            );
            controller.state = const CartState(draftOrderId: orderId);
            return controller;
          }),
          cartLinesProvider.overrideWith(
            (Ref ref, String requestedOrderId) async {
              if (requestedOrderId == orderId) {
                return <CartLine>[line];
              }
              return const <CartLine>[];
            },
          ),
          orderApprovalProvider.overrideWith(
            (Ref ref, String requestedOrderId) async {
              return OrderApprovalState.notRequired(requestedOrderId);
            },
          ),
          priceResolutionServiceProvider.overrideWithValue(
            FakePriceResolutionService(
              onResolve: ({
                required String companyId,
                required String variantId,
                required num qty,
                DateTime? at,
              }) {
                if (variantId == 'VAR-1' && qty.toDouble() == 3) {
                  return const PriceResolution(
                    price: 19.5,
                    currency: 'USD',
                    vatIncluded: true,
                    source: 'contract',
                  );
                }
                return null;
              },
            ),
          ),
          sessionControllerProvider.overrideWith(
            (ref) => FakeSessionController(_fakeSession()),
          ),
          quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
        ],
        extraDelegates: const [MarketplaceLocalizations.delegate],
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('checkout_line_price_VAR-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('checkout_line_contract_chip_VAR-1')),
      findsOneWidget,
    );
  });
}
