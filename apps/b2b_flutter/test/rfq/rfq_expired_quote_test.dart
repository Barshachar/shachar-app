import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_utils/tester_view_compat.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('he_IL');
  });

  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  testWidgets(
      'expired quote disabled while alternate navigates to order detail',
      (WidgetTester tester) async {
    await tester.setDevicePixelRatio(1.0);
    await tester.setSurfaceSize(const Size(1200, 2400));

    const String rfqId = 'RFQ-EXPIRED-1';
    const String expiredQuoteId = 'QUOTE-B';
    const String activeQuoteId = 'QUOTE-A';

    final RfqDetail detail = RfqDetail(
      id: rfqId,
      status: 'quoted',
      createdAt: DateTime(2024, 6, 1, 9, 0),
      needBy: null,
      reference: 'RFQ-552',
      terms: const {},
      metadata: const {},
      items: const [
        RfqItem(
          id: 'item-1',
          rfqId: rfqId,
          qty: 4,
          description: 'Item',
        ),
      ],
      quotes: [
        RfqQuote(
          id: activeQuoteId,
          rfqId: rfqId,
          status: 'submitted',
          createdAt: DateTime(2024, 6, 2, 12, 0),
          terms: const {'valid_until': '2099-01-01T00:00:00Z'},
          total: 3200,
        ),
        RfqQuote(
          id: expiredQuoteId,
          rfqId: rfqId,
          status: 'submitted',
          createdAt: DateTime(2024, 6, 2, 12, 30),
          terms: const {'valid_until': '2000-01-01T00:00:00Z'},
          total: 3000,
        ),
      ],
      messages: const [],
    );

    late _RecordingRfqActionController controller;

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
          controller = _RecordingRfqActionController(ref);
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

    expect(find.byKey(const ValueKey('rfq_quote_expired_badge_QUOTE-B')),
        findsOneWidget);

    final Finder expiredButtonFinder =
        find.byKey(const ValueKey('rfq_accept_quote_btn_QUOTE-B'));
    final FilledButton expiredButton =
        tester.widget<FilledButton>(expiredButtonFinder);
    expect(expiredButton.onPressed, isNull);

    final Finder activeButtonFinder =
        find.byKey(const ValueKey('rfq_accept_quote_btn_QUOTE-A'));
    final FilledButton activeButton =
        tester.widget<FilledButton>(activeButtonFinder);
    expect(activeButton.onPressed, isNotNull);

    await tester.tap(activeButtonFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(controller.lastAcceptedQuote, activeQuoteId);
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

class _RecordingRfqActionController extends RfqActionController {
  _RecordingRfqActionController(Ref ref) : super(ref, _NoopRfqRemoteService());

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
