import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/colors.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/scripts_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ContentSparkApp());
}

class ContentSparkApp extends StatelessWidget {
  const ContentSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: Colors.white,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScriptsProvider()),
      ],
      child: MaterialApp(
        title: 'ContentSpark',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: baseScheme,
          scaffoldBackgroundColor: AppColors.light,
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.dark,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
        },
      ),
    );
  }
}
