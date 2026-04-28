// lib/screens/about/about_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.aboutTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                AppStrings.appVersion,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Açıklama
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceVar),
              ),
              child: const Text(
                AppStrings.aboutDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bilgi kartları
            _infoCard(Icons.code_rounded, AppColors.primary, 'Teknoloji', 'Flutter & FastAPI'),
            const SizedBox(height: 12),
            _infoCard(Icons.person_rounded, AppColors.secondary, 'Geliştirici', 'Emirhan'),
            const SizedBox(height: 12),
            _infoCard(Icons.favorite_rounded, AppColors.accent, 'Yapıldı', '❤️ ile Türkiye\'de'),
            const SizedBox(height: 12),
            _infoCard(Icons.calendar_today_rounded, AppColors.success, 'Yıl', '2026'),
            const SizedBox(height: 40),

            // Alt bilgi
            const Text(
              '© 2026 Daily Programming\nTüm hakları saklıdır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVar),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
