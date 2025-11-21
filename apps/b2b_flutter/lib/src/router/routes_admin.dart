import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_audit_log_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_catalog_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_contact_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_customers_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_dashboard_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_dock_scheduling_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_export_scheduler_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_orders_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_order_approval_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_payables_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_price_lists_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_reports_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_settings_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_users_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/vendor_queue_page.dart';
import 'package:ashachar_marketplace/src/features/support/presentation/support_tickets_page.dart';
import 'package:ashachar_marketplace/src/router/guards/auth_guards.dart';
import 'package:ashachar_marketplace/src/router/route_config.dart';

List<RouteDefinition> buildAdminRoutes() => <RouteDefinition>[
      RouteDefinition(
        path: '/admin',
        name: 'admin-home',
        guards: <RouteGuard>[
          requireAuthenticated(),
          requireRoles({UserRole.admin}),
        ],
        builder: (context, state) => const AdminDashboardPage(),
        routes: <RouteDefinition>[
          RouteDefinition(
            path: 'vendor-queue',
            name: 'vendor-queue',
            builder: (context, state) => const VendorQueuePage(),
          ),
          RouteDefinition(
            path: 'customers',
            name: 'admin-customers',
            builder: (context, state) => const AdminCustomersPage(),
          ),
          RouteDefinition(
            path: 'users',
            name: 'admin-users',
            builder: (context, state) => const AdminUsersPage(),
          ),
          RouteDefinition(
            path: 'catalog',
            name: 'admin-catalog',
            builder: (context, state) => const AdminCatalogPage(),
          ),
          RouteDefinition(
            path: 'price-lists',
            name: 'price-lists',
            builder: (context, state) => const AdminPriceListsPage(),
          ),
          RouteDefinition(
            path: 'orders',
            name: 'admin-orders',
            builder: (context, state) => const AdminOrdersPage(),
          ),
          RouteDefinition(
            path: 'reports',
            name: 'admin-reports',
            builder: (context, state) => const AdminReportsPage(),
          ),
          RouteDefinition(
            path: 'support',
            name: 'admin-support',
            builder: (context, state) => const SupportTicketsPage(),
          ),
          RouteDefinition(
            path: 'contact',
            name: 'admin-contact',
            builder: (context, state) => const AdminContactPage(),
          ),
          RouteDefinition(
            path: 'dock-scheduling',
            name: 'admin-dock',
            builder: (context, state) => const AdminDockSchedulingPage(),
          ),
          RouteDefinition(
            path: 'payables',
            name: 'admin-payables',
            builder: (context, state) => const AdminPayablesPage(),
          ),
          RouteDefinition(
            path: 'exports',
            name: 'admin-exports',
            builder: (context, state) => const AdminExportSchedulerPage(),
          ),
          RouteDefinition(
            path: 'order-approval',
            name: 'admin-order-approval',
            builder: (context, state) => const AdminOrderApprovalPage(),
          ),
          RouteDefinition(
            path: 'audit-log',
            name: 'admin-audit-log',
            builder: (context, state) => const AdminAuditLogPage(),
          ),
          RouteDefinition(
            path: 'settings',
            name: 'admin-settings',
            builder: (context, state) => const AdminSettingsPage(),
          ),
        ],
      ),
    ];
