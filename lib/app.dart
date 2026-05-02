import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/core/router.dart';
import 'package:menu_ordering_flutter/core/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChopChop',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
