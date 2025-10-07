import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ashachar_marketplace/main.dart' as entry;
import 'package:ashachar_marketplace/src/app/app_bootstrap.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/router/app_router.dart';

Future<void> _goToRoute(
  WidgetTester tester,
  ProviderContainer container,
  String route,
) async {
  await tester.runAsync(() async {
    final GoRouter router = container.read(appRouterProvider);
    router.go(route);
  });
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture catalog and quick-order screens', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(const {});
    await AppBootstrap(container: container).initialize();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const entry.MarketplaceApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await binding.convertFlutterSurfaceToImage();

    await _goToRoute(tester, container, '/catalog');
    expect(find.byType(CatalogPage), findsOneWidget);
    await binding.takeScreenshot('catalog_search');

    await _goToRoute(tester, container, '/catalog/quick-order');
    expect(find.byType(QuickOrderPage), findsOneWidget);
    await binding.takeScreenshot('quick_order');
  });
}
