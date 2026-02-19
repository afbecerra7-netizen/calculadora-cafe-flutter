import 'package:flutter/material.dart';

import 'features/calculator/presentation/calculator_page.dart';

class CafeApp extends StatelessWidget {
  const CafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFFC56F1A));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora Cafe',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF6EFE7),
      ),
      home: const CalculatorPage(),
    );
  }
}
