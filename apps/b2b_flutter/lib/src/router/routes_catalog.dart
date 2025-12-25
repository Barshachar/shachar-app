import 'package:ashachar_marketplace/src/app/home/home_page.dart';
import 'package:ashachar_marketplace/src/auth/login_page.dart';
import 'package:ashachar_marketplace/src/features/billing/presentation/business_credit_page.dart';
import 'package:ashachar_marketplace/src/features/billing/presentation/payment_terms_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_search_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/finance/presentation/cost_centers_page.dart';
import 'package:ashachar_marketplace/src/features/promotions/presentation/promotions_page.dart';
import 'package:ashachar_marketplace/src/router/route_config.dart';

List<RouteDefinition> buildCatalogRoutes() => <RouteDefinition>[
      RouteDefinition(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      RouteDefinition(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      RouteDefinition(
        path: '/catalog',
        name: 'catalog',
        builder: (context, state) => const CatalogPage(),
        routes: <RouteDefinition>[
          RouteDefinition(
            path: 'product/:id',
            name: 'product',
            builder: (context, state) => ProductPage(
              productId: state.pathParameters['id']!,
            ),
          ),
          RouteDefinition(
            path: 'search',
            name: 'catalog-search',
            builder: (context, state) => const CatalogSearchPage(),
          ),
          RouteDefinition(
            path: 'quick-order',
            name: 'quick-order',
            builder: (context, state) {
              final String? tabParam = state.uri.queryParameters['tab'];
              final QuickNavTab initialTab = QuickNavTab.values.firstWhere(
                (QuickNavTab tab) => tab.name == tabParam,
                orElse: () => QuickNavTab.quickOrder,
              );
              return QuickOrderPage(initialTab: initialTab);
            },
          ),
        ],
      ),
      RouteDefinition(
        path: '/finance/business-credit',
        name: 'business-credit',
        builder: (context, state) => const BusinessCreditPage(),
      ),
      RouteDefinition(
        path: '/finance/payment-terms',
        name: 'payment-terms',
        builder: (context, state) => const PaymentTermsPage(),
      ),
      RouteDefinition(
        path: '/finance/cost-centers',
        name: 'cost-centers',
        builder: (context, state) => const CostCentersPage(),
      ),
      RouteDefinition(
        path: '/promotions',
        name: 'promotions',
        builder: (context, state) => const PromotionsPage(),
      ),
    ];
