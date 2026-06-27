import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:ashachar_marketplace/src/app/home/home_page.dart';
import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/auth/login_page.dart';
import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_audit_log_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_catalog_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_contact_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_customers_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_dashboard_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_dock_scheduling_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_orders_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_order_approval_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_payables_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_price_lists_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_reports_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_settings_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_users_page.dart';
import 'package:ashachar_marketplace/src/features/admin/cashback/presentation/admin_cashback_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_export_scheduler_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/vendor_queue_page.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/approvals_inbox_page.dart';
import 'package:ashachar_marketplace/src/features/billing/presentation/business_credit_page.dart';
import 'package:ashachar_marketplace/src/features/billing/presentation/payment_terms_page.dart';
import 'package:ashachar_marketplace/src/features/cashback/presentation/cashback_page.dart';
import 'package:ashachar_marketplace/src/features/finance/presentation/cost_centers_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_search_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/customer/customer_home_page.dart';
import 'package:ashachar_marketplace/src/features/customer/customer_company_profile_page.dart';
import 'package:ashachar_marketplace/src/features/customer/profile_page.dart';
import 'package:ashachar_marketplace/src/features/customer/settings_page.dart';
import 'package:ashachar_marketplace/src/features/customer/help_page.dart';
import 'package:ashachar_marketplace/src/features/lists/presentation/saved_lists_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/order_detail_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/packing_station_page.dart';
import 'package:ashachar_marketplace/src/features/inventory/presentation/putaway_map_page.dart';
import 'package:ashachar_marketplace/src/features/promotions/presentation/promotions_page.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_orders_page.dart';
import 'package:ashachar_marketplace/src/features/support/presentation/support_tickets_page.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_products_page.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_directory_page.dart';
import 'package:ashachar_marketplace/src/widgets/loading_scaffold.dart';

const String _initialOverride =
    String.fromEnvironment('INITIAL_ROUTE', defaultValue: '/');

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  final LoggingNavigatorObserver navObserver = LoggingNavigatorObserver();
  final sub = ref.listen<AsyncValue<UserProfile?>>(
    userProfileProvider,
    (_, __) => refreshNotifier.value++,
    fireImmediately: true,
  );
  ref.onDispose(sub.close);
  final GoRouter router = GoRouter(
    initialLocation: _initialOverride,
    refreshListenable: refreshNotifier,
    observers: [navObserver],
    routes: [
      loadingRoute,
      GoRoute(
        path: '/',
        name: 'root',
        redirect: (context, state) {
          final user = ref.read(userProfileProvider).asData?.value;
          if (user == null) {
            return '/home';
          }
          switch (user.role) {
            case UserRole.admin:
              return '/admin';
            case UserRole.vendorAdmin:
            case UserRole.vendorUser:
              return '/vendor';
            case UserRole.customerAdmin:
            case UserRole.buyer:
              return '/customer';
          }
        },
      ),
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            builder: (context, state) => const CatalogPage(),
            routes: [
              GoRoute(
                path: 'product/:id',
                name: 'product',
                builder: (context, state) => ProductPage(
                  productId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'search',
                name: 'catalog-search',
                builder: (context, state) => const CatalogSearchPage(),
              ),
              GoRoute(
                path: 'quick-order',
                name: 'quick-order',
                builder: (context, state) => const QuickOrderPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/finance/business-credit',
            name: 'business-credit',
            builder: (context, state) => const BusinessCreditPage(),
          ),
          GoRoute(
            path: '/finance/payment-terms',
            name: 'payment-terms',
            builder: (context, state) => const PaymentTermsPage(),
          ),
          GoRoute(
            path: '/finance/cashback',
            name: 'cashback',
            builder: (context, state) => const CashbackPage(),
          ),
          GoRoute(
            path: '/finance/cost-centers',
            name: 'cost-centers',
            builder: (context, state) => const CostCentersPage(),
          ),
          GoRoute(
            path: '/promotions',
            name: 'promotions',
            builder: (context, state) => const PromotionsPage(),
          ),
          GoRoute(
            path: '/customer',
            name: 'customer-home',
            builder: (context, state) => const CustomerHomePage(),
            routes: [
              GoRoute(
                path: 'cart',
                name: 'cart',
                builder: (context, state) => const CartPage(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    name: 'checkout',
                    builder: (context, state) {
                      final String orderId = (state.extra as String?) ?? '';
                      return CheckoutPage(orderId: orderId);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'orders',
                name: 'customer-orders',
                builder: (context, state) => const OrdersPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'order-detail',
                    builder: (context, state) => OrderDetailPage(
                      orderId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'approvals',
                name: 'customer-approvals',
                builder: (context, state) => const ApprovalsInboxPage(),
              ),
              GoRoute(
                path: 'lists',
                name: 'saved-lists',
                builder: (context, state) => const SavedListsPage(),
              ),
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
              GoRoute(
                path: 'company-profile',
                name: 'company-profile',
                builder: (context, state) {
                  final String? companyId = state.extra as String?;
                  return CustomerCompanyProfilePage(companyId: companyId);
                },
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: 'help',
                name: 'help',
                builder: (context, state) => const HelpPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/vendor',
            name: 'vendor-home',
            builder: (context, state) => const VendorOrdersPage(),
            routes: [
              GoRoute(
                path: 'products',
                name: 'vendor-products',
                builder: (context, state) => const VendorProductsPage(),
              ),
              GoRoute(
                path: 'directory',
                name: 'vendor-directory',
                builder: (context, state) => const VendorDirectoryPage(),
              ),
              GoRoute(
                path: 'packing-station',
                name: 'packing-station',
                builder: (context, state) => const PackingStationPage(),
              ),
              GoRoute(
                path: 'putaway-map',
                name: 'putaway-map',
                builder: (context, state) => const PutawayMapPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/admin',
            name: 'admin-home',
            builder: (context, state) => const AdminDashboardPage(),
            routes: [
              GoRoute(
                path: 'vendor-queue',
                name: 'vendor-queue',
                builder: (context, state) => const VendorQueuePage(),
              ),
              GoRoute(
                path: 'customers',
                name: 'admin-customers',
                builder: (context, state) => const AdminCustomersPage(),
              ),
              GoRoute(
                path: 'users',
                name: 'admin-users',
                builder: (context, state) => const AdminUsersPage(),
              ),
              GoRoute(
                path: 'catalog',
                name: 'admin-catalog',
                builder: (context, state) => const AdminCatalogPage(),
              ),
              GoRoute(
                path: 'price-lists',
                name: 'price-lists',
                builder: (context, state) => const AdminPriceListsPage(),
              ),
              GoRoute(
                path: 'orders',
                name: 'admin-orders',
                builder: (context, state) => const AdminOrdersPage(),
              ),
              GoRoute(
                path: 'reports',
                name: 'admin-reports',
                builder: (context, state) => const AdminReportsPage(),
              ),
              GoRoute(
                path: 'support',
                name: 'admin-support',
                builder: (context, state) => const SupportTicketsPage(),
              ),
              GoRoute(
                path: 'contact',
                name: 'admin-contact',
                builder: (context, state) => const AdminContactPage(),
              ),
              GoRoute(
                path: 'dock-scheduling',
                name: 'admin-dock',
                builder: (context, state) => const AdminDockSchedulingPage(),
              ),
              GoRoute(
                path: 'payables',
                name: 'admin-payables',
                builder: (context, state) => const AdminPayablesPage(),
              ),
              GoRoute(
                path: 'exports',
                name: 'admin-exports',
                builder: (context, state) => const AdminExportSchedulerPage(),
              ),
              GoRoute(
                path: 'order-approval',
                name: 'admin-order-approval',
                builder: (context, state) => const AdminOrderApprovalPage(),
              ),
              GoRoute(
                path: 'audit-log',
                name: 'admin-audit-log',
                builder: (context, state) => const AdminAuditLogPage(),
              ),
              GoRoute(
                path: 'cashback',
                name: 'admin-cashback',
                builder: (context, state) => const AdminCashbackPage(),
              ),
              GoRoute(
                path: 'settings',
                name: 'admin-settings',
                builder: (context, state) => const AdminSettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(userProfileProvider);
      if (auth.isLoading) {
        return state.uri.toString() == '/loading' ? null : '/loading';
      }
      if (state.matchedLocation == '/loading' && auth.hasValue) {
        return '/';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
  navObserver.attach(router);
  ref.onDispose(() {
    sub.close();
    refreshNotifier.dispose();
  });
  return router;
});

final appThemeProvider = Provider<AppTheme>((ref) => AppTheme());

class LoggingNavigatorObserver extends NavigatorObserver {
  GoRouter? _router;

  void attach(GoRouter router) {
    _router = router;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('replace', newRoute, oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('remove', route, previousRoute);
  }

  void _log(
      String event, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final GoRouter? router = _router;
    if (router == null) {
      return;
    }
    GoRouterState? state;
    try {
      if (router.routerDelegate.currentConfiguration.isNotEmpty) {
        state = router.routerDelegate.state;
      }
    } on Object {
      state = null;
    }
    final Map<String, String> params =
        state?.pathParameters ?? const <String, String>{};
    final String name =
        state?.name ?? state?.fullPath ?? route?.settings.name ?? 'unknown';
    final String location = state?.uri.toString() ?? 'unknown';
    final String previous =
        previousRoute?.settings.name ?? state?.matchedLocation ?? 'none';
    debugPrint(
      '[NAV] event=$event location=$location name=$name params=$params prev=$previous',
    );
  }
}

final localeProvider = StateProvider<Locale>((ref) => const Locale('he'));

final loadingRoute = GoRoute(
  path: '/loading',
  name: 'loading',
  builder: (context, state) => const LoadingScaffold(),
);

class AppTheme {
  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        fontFamily: 'Rubik',
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Rubik',
      );

  ThemeMode get mode => ThemeMode.system;
}
