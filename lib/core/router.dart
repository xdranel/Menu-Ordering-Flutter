import 'package:go_router/go_router.dart';
import 'package:menu_ordering_flutter/screens/cart_screen.dart';
import 'package:menu_ordering_flutter/screens/menu_screen.dart';
import 'package:menu_ordering_flutter/screens/order_confirmation_screen.dart';
import 'package:menu_ordering_flutter/screens/order_tracking_screen.dart';
import 'package:menu_ordering_flutter/screens/payment_screen.dart';



class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/menu',
    routes: [
      GoRoute(path: '/menu', builder: (context, _) => const MenuScreen()),
      GoRoute(path: '/cart', builder: (context, _) => const CartScreen()),
      GoRoute(path: '/payment', builder: (context, _) => const PaymentScreen()),
      GoRoute(
        path: '/order-confirmation/:orderNumber',
        builder: (_, state) => OrderConfirmationScreen(
          orderNumber: state.pathParameters['orderNumber']!,
        ),
      ),
      GoRoute(
        path: '/order-tracking/:orderNumber',
        builder: (_, state) => OrderTrackingScreen(
          orderNumber: state.pathParameters['orderNumber']!,
        ),
      ),
    ],
  );
}
