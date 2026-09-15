import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

// Notificador global reativo para troca de temas
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ceibailvflemlupugxmh.supabase.co',
    anonKey: 'sb_publishable_UKeD5rOpUblDtqID0BMa-Q_BFNrygON',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RunMind',
          themeMode: currentThemeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F7),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFFFF2D55),
              unselectedItemColor: Colors.grey,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121217),
            cardColor: const Color(0xFF1C1C22),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF121217),
              selectedItemColor: Color(0xFFFF2D55),
              unselectedItemColor: Colors.grey,
            ),
          ),
          home: StreamBuilder<AuthState>(
            stream: supabase.auth.onAuthStateChange,
            builder: (context, snapshot) {
              final session = supabase.auth.currentSession;
              if (session != null) {
                return const MainScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
