import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_guide_screen.dart';
import 'screens/home_screen.dart';
import 'utils/settings_manager.dart';

void main() {
  runApp(const OrigamiApp());
}

class OrigamiApp extends StatelessWidget {
  const OrigamiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([SettingsManager.isDarkMode, SettingsManager.language]),
      builder: (context, child) {
        final isDark = SettingsManager.isDarkMode.value;
        return MaterialApp(
          title: 'Origami Master',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            fontFamily: 'Roboto',
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E293B),
              elevation: 0.5,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.indigo,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E293B), // Slate 800
              foregroundColor: Colors.white,
              elevation: 0.5,
            ),
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/login-guide': (context) => const LoginGuideScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
