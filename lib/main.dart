import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:menu_ordering_flutter/app.dart';
import 'package:menu_ordering_flutter/providers/cart_provider.dart';
import 'package:menu_ordering_flutter/providers/menu_provider.dart';
import 'package:menu_ordering_flutter/providers/order_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const App(),
    ),
  );
}
