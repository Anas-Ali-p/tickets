import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

import 'controllers/database_controller.dart';

import 'controllers/input_controller.dart';

import 'views/input_page.dart';

import 'views/records_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // طلب أذونات التخزين
  await _requestPermissions();

  // Initialize database controller

  final dbController = DatabaseController();

  await dbController.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InputController()),
        Provider.value(value: dbController),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  await [
    Permission.storage,
    Permission.manageExternalStorage,
  ].request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المسبح',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1A237E),
        scaffoldBackgroundColor: Colors.transparent,
        cardTheme: CardTheme(
          color: Colors.grey[900]!.withOpacity(0.8),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textTheme: const TextTheme(
          headlineMedium:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850]!.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3949AB), width: 2),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Directionality(
            textDirection: TextDirection.rtl, child: InputPage()),
        '/records': (context) => const Directionality(
            textDirection: TextDirection.rtl, child: RecordsPage()),
      },
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A237E),
        secondary: const Color(0xFF3949AB),
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      fontFamily: 'Cairo',
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.white70,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A237E),
        elevation: 2,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
