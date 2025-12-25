import 'package:ashachar_marketplace/src/features/orders/presentation/cart_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/order_detail_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_page.dart';
import 'package:ashachar_marketplace/src/router/route_config.dart';

List<RouteDefinition> buildCustomerOrdersRoutes() => <RouteDefinition>[
      RouteDefinition(
        path: 'cart',
        name: 'cart',
        builder: (context, state) => const CartPage(),
        routes: <RouteDefinition>[
          RouteDefinition(
            path: 'checkout',
            name: 'checkout',
            builder: (context, state) {
              final String orderId = (state.extra as String?) ?? '';
              return CheckoutPage(orderId: orderId);
            },
          ),
        ],
      ),
      RouteDefinition(
        path: 'orders',
        name: 'customer-orders',
        builder: (context, state) => const OrdersPage(),
        routes: <RouteDefinition>[
          RouteDefinition(
            path: ':id',
            name: 'order-detail',
            builder: (context, state) => OrderDetailPage(
              orderId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ];
