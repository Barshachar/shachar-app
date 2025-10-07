import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_utils/tester_view_compat.dart';

void main() {
  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  testWidgets(
      'customer selects specific vendor quote and navigates to order detail',
      (WidgetTester tester) async {
    await tester.setDevicePixelRatio(1.0);
    await tester.setSurfaceSize(const Size(1200, 2400));
    const String rfqId = 'rfq-multi-1';
    const String quoteAId = 'QUOTE-A';
    const String quoteBId = 'QUOTE-B';

    final RfqDetail detail = RfqDetail(
      id: rfqId,
      status: 'quoted',
      createdAt: DateTime(2024, 4, 2, 12, 0),
      needBy: null,
      reference: 'RFQ-552',
      terms: const {'memo': 'ציינו זמן אספקה'},
      metadata: const {},
      items: const [
        RfqItem(
          id: 'item-1',
          rfqId: rfqId,
          qty: 12,
          uom: 'EA',
          description: 'מסך 27 אינץ\' IPS',
          sku: 'SKU-27',
          variantId: 'VAR-27',
        ),
      ],
      quotes: [
        RfqQuote(
          id: quoteAId,
          rfqId: rfqId,
          status: 'submitted',
          createdAt: DateTime(2024, 4, 3, 9, 15),
          vendorCompanyId: 'COMP-A',
          terms: const {'warranty': '12m'},
          total: 4800,
        ),
        RfqQuote(
          id: quoteBId,
          rfqId: rfqId,
          status: 'submitted',
          createdAt: DateTime(2024, 4, 3, 9, 45),
          vendorCompanyId: 'COMP-B',
          terms: const {'warranty': '24m'},
          total: 4500,
        ),
      ],
      messages: const <RfqMessage>[],
    );

    late _FakeRfqActionController controller;

    final GoRouter router = GoRouter(
      initialLocation: '/customer/rfqs/$rfqId',
      routes: <RouteBase>[
        GoRoute(
          path: '/customer/rfqs/:rfqId',
          builder: (BuildContext context, GoRouterState state) =>
              CustomerRfqDetailPage(
            rfqId: state.pathParameters['rfqId']!,
          ),
        ),
        GoRoute(
          path: '/customer/orders/:orderId',
          builder: (BuildContext context, GoRouterState state) =>
              _OrderDetailStub(orderId: state.pathParameters['orderId']!),
        ),
      ],
    );

    final ProviderContainer container = ProviderContainer(
      overrides: [
        rfqDetailProvider.overrideWith((ref, id) async {
          if (id != rfqId) {
            throw StateError('unexpected rfqId: $id');
          }
          return detail;
        }),
        rfqActionControllerProvider.overrideWith((ref) {
          controller = _FakeRfqActionController(ref);
          return controller;
        }),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildRouterApp(router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('rfq_quote_card_QUOTE-A')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('rfq_quote_card_QUOTE-B')), findsOneWidget);

    final Finder acceptQuoteBFinder =
        find.byKey(const ValueKey('rfq_accept_quote_btn_QUOTE-B'));
    await tester.ensureVisible(acceptQuoteBFinder);
    await tester.tap(acceptQuoteBFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(controller.lastAcceptedQuote, quoteBId);
    expect(find.byKey(const ValueKey('order_detail_root')), findsOneWidget);
  });
}

MaterialApp _buildRouterApp(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    supportedLocales: const [Locale('en'), Locale('he')],
    localizationsDelegates: const [
      MarketplaceLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

class _FakeRfqActionController extends RfqActionController {
  _FakeRfqActionController(Ref ref) : super(ref, _NoopRfqRemoteService());

  String? lastAcceptedQuote;

  @override
  Future<String> acceptQuote(String quoteId) async {
    lastAcceptedQuote = quoteId;
    return 'order-draft-$quoteId';
  }
}

class _NoopRfqRemoteService extends RfqRemoteService {
  _NoopRfqRemoteService()
      : super(
          SupabaseClient(
            'https://example.supabase.co',
            'public-test-key',
            authOptions: const AuthClientOptions(autoRefreshToken: false),
          ),
        );
}

class _OrderDetailStub extends StatelessWidget {
  const _OrderDetailStub({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('order_detail_root'),
      body: Center(child: Text('order-$orderId')),
    );
  }
}
