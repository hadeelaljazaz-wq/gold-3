import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables safely (skip for web - uses hardcoded fallbacks)
  try {
    await dotenv.load(fileName: 'project.env').timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        print('⚠️ dotenv load timeout - using fallback API keys');
      },
    );
  } catch (_) {
    print('⚠️ dotenv not loaded - using fallback API keys (normal for web)');
  }

  // تم إزالة LicenseService - النظام الموحد لا يحتاج تهيئة في main

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: GoldenNightmareApp(),
    ),
  );
}
