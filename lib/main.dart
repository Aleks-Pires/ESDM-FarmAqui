import 'package:flutter/material.dart';

void main() {
  runApp(const FarmaAquiApp());
}

class FarmaAquiApp extends StatelessWidget {
  const FarmaAquiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmaAqui',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF157A6E),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('FarmaAqui - projeto inicial'),
        ),
      ),
    );
  }
}
