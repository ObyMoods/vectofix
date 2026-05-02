import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';

// Pages
import 'landing.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'purchase_page.dart';
import 'bugs/home_page.dart';
import 'manager/admin_page.dart';
import 'services/audio_handler.dart';
import 'build_apk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('DateFormat error: $e');
  }

  // Inisialisasi audio handler
  try {
    await initAudioHandlerIfNeeded();
  } catch (e) {
    debugPrint('Audio handler init failed: $e');
  }

  // Request permission notifikasi untuk Android 13+
  try {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VECTO',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Orbitron',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark().copyWith(secondary: Colors.purple),
      ),
      home: const LandingPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => DashboardPage(
                username: args['username'] ?? '',
                password: args['password'] ?? '',
                role: args['role'] ?? 'user',
                expiredDate: args['expiredDate'],
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                listDoos: List<Map<String, dynamic>>.from(args['listDoos'] ?? []),
                news: List<Map<String, dynamic>>.from(args['news'] ?? []),
              ),
            );

          case '/home':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => HomePage(
                username: args['username'] ?? '',
                password: args['password'] ?? '',
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                role: args['role'] ?? 'user',
                expiredDate: args['expiredDate'],
                sessionKey: args['sessionKey'],
                initialCoins: args['initialCoins'] ?? 100,
              ),
            );

          case '/admin':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => AdminPage(
                sessionKey: args['sessionKey'],
                currentUserRole: args['role'] ?? 'admin',
              ),
            );

          case '/purchase':
            return PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => const PurchasePage(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            );

          // Route untuk Build Apk Flutter
          case '/build_apk':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => BuildApkFlutter(
                sessionKey: args?['sessionKey'],
                username: args?['username'],
                role: args?['role'],
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Text(
                    '404 - Not Found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}