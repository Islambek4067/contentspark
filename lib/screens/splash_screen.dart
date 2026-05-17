import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    if (!_navigated && auth.isReady) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(
          auth.isAuthenticated ? HomeScreen.routeName : LoginScreen.routeName,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLogo(size: 86),
                SizedBox(height: 28),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
