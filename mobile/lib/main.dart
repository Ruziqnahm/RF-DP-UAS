import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'RF Digital Printing',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashPage(),
      ),
    );
  }
}