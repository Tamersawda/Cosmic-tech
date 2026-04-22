import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/storage/shared_pref_service.dart';
import 'package:frontend/modules/auth/presentation/screens/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Must run before anything else ─────────────────────────────────────────
  await SharedPrefService.instance.init();

  runApp(
    const ProviderScope(   // ← Riverpod won't work without this
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LandingPage()
    );
  }
}