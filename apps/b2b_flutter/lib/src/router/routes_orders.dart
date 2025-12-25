import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/approvals_inbox_page.dart';
import 'package:ashachar_marketplace/src/features/customer/about_page.dart';
import 'package:ashachar_marketplace/src/features/customer/customer_company_profile_page.dart';
import 'package:ashachar_marketplace/src/features/customer/customer_home_page.dart';
import 'package:ashachar_marketplace/src/features/customer/help_page.dart';
import 'package:ashachar_marketplace/src/features/customer/profile_page.dart';
import 'package:ashachar_marketplace/src/features/customer/settings_page.dart';
import 'package:ashachar_marketplace/src/features/lists/presentation/saved_lists_page.dart';
import 'package:ashachar_marketplace/src/features/orders/orders_routes.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/packing_station_page.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_directory_page.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_orders_page.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_products_page.dart';
import 'package:ashachar_marketplace/src/features/inventory/presentation/putaway_map_page.dart';
import 'package:ashachar_marketplace/src/core/onboarding/onboarding_gate.dart';
import 'package:ashachar_marketplace/src/router/guards/auth_guards.dart';
import 'package:ashachar_marketplace/src/router/route_config.dart';

List<RouteDefinition> buildOrderRoutes() => <RouteDefinition>[
      RouteDefinition(
        path: '/customer',
        name: 'customer-home',
        guards: <RouteGuard>[
          requireAuthenticated(),
          requireCompany(),
          requireRoles({UserRole.customerAdmin, UserRole.buyer}),
        ],
        builder: (context, state) => const OnboardingGate(
          child: CustomerHomePage(),
        ),
        routes: <RouteDefinition>[
          ...buildCustomerOrdersRoutes(),
          RouteDefinition(
            path: 'approvals',
            name: 'customer-approvals',
            builder: (context, state) => const ApprovalsInboxPage(),
          ),
          RouteDefinition(
            path: 'lists',
            name: 'saved-lists',
            builder: (context, state) => const SavedListsPage(),
          ),
          RouteDefinition(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          RouteDefinition(
            path: 'company-profile',
            name: 'company-profile',
            builder: (context, state) {
              final String? companyId = state.extra as String?;
              return CustomerCompanyProfilePage(companyId: companyId);
            },
          ),
          RouteDefinition(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          RouteDefinition(
            path: 'help',
            name: 'help',
            builder: (context, state) => const HelpPage(),
          ),
          RouteDefinition(
            path: 'about',
            name: 'about',
            builder: (context, state) => const AboutPage(),
          ),
        ],
      ),
      RouteDefinition(
        path: '/vendor',
        name: 'vendor-home',
        guards: <RouteGuard>[
          requireAuthenticated(),
          requireCompany(),
          requireRoles({UserRole.vendorAdmin, UserRole.vendorUser}),
        ],
        builder: (context, state) => const VendorOrdersPage(),
        routes: <RouteDefinition>[
          RouteDefinition(
            path: 'products',
            name: 'vendor-products',
            builder: (context, state) => const VendorProductsPage(),
          ),
          RouteDefinition(
            path: 'directory',
            name: 'vendor-directory',
            builder: (context, state) => const VendorDirectoryPage(),
          ),
          RouteDefinition(
            path: 'packing-station',
            name: 'packing-station',
            builder: (context, state) => const PackingStationPage(),
          ),
          RouteDefinition(
            path: 'putaway-map',
            name: 'putaway-map',
            builder: (context, state) => const PutawayMapPage(),
          ),
        ],
      ),
    ];
