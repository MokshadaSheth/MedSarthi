import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sarathi/features/app/splash_screen/splash_screen.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/home_page.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/login_page.dart';
import 'package:med_sarathi/themes/theme_provider.dart';
import 'package:med_sarathi/themes/light_theme.dart';
import 'package:med_sarathi/themes/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/noti_service.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/IntakeProgressProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => IntakeProgressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MedSarathi',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}