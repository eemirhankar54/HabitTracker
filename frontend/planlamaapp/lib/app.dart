// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Daily Programming',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: const _RootRouter(),
  );
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⚡', style: TextStyle(fontSize: 52)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ],
        )),
      );
    }

    return auth.isLoggedIn ? const HomeScreen() : const AuthScreen();
  }
}
