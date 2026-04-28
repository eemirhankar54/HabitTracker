// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final username = user?['username'] ?? 'Kullanıcı';
    final email = user?['email'] ?? 'email@example.com';
    final createdAt = user?['created_at'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // ── Profil Kartı ──
            _buildProfileCard(username, email, createdAt),
            const SizedBox(height: 24),

            // ── KVKK Aydınlatma Metni ──
            _buildSection(
              icon: Icons.shield_outlined,
              iconColor: AppColors.secondary,
              title: AppStrings.kvkkTitle,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  AppStrings.kvkkText,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── SSS ──
            _buildSection(
              icon: Icons.help_outline_rounded,
              iconColor: AppColors.warning,
              title: AppStrings.faqTitle,
              child: Column(
                children: [
                  _faqItem(
                    'Alışkanlık nasıl eklerim?',
                    'Alışkanlıklarım sekmesindeki + butonuna basarak yeni bir alışkanlık ekleyebilirsin.',
                  ),
                  _faqItem(
                    'Seri (streak) nasıl çalışır?',
                    'Her gün alışkanlığını tamamladığında serin bir artar. Bir gün kaçırırsan seri sıfırlanır.',
                  ),
                  _faqItem(
                    'Bildirim saatini nasıl değiştiririm?',
                    'Menüden Bildirimler seçeneğine giderek her alışkanlık için hatırlatıcı saatini ayarlayabilirsin.',
                  ),
                  _faqItem(
                    'Hesabımı silersem ne olur?',
                    'Hesabını sildiğinde tüm verilerin kalıcı olarak silinir ve geri alınamaz.',
                  ),
                  _faqItem(
                    'Verilerim güvende mi?',
                    'Evet, verilerin şifreli olarak saklanır ve üçüncü taraflarla paylaşılmaz.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Yardım & Destek ──
            _buildSection(
              icon: Icons.support_agent_rounded,
              iconColor: AppColors.success,
              title: AppStrings.helpTitle,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.helpText,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'destek@dailyprogramming.app',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Hesap Eylemleri ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Çıkış Yap Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        AppStrings.logout,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: BorderSide(color: AppColors.warning.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hesabı Sil Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDeleteAccount(context),
                      icon: const Icon(Icons.delete_forever_rounded, size: 20),
                      label: const Text(
                        AppStrings.deleteAccount,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: BorderSide(color: AppColors.accent.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(String username, String email, String createdAt) {
    String memberDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        memberDate = '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.primary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kullanıcı adı
          Text(
            username,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Email
          Text(
            email,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),

          if (memberDate.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '📅 ${AppStrings.memberSince}: $memberDate',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceVar),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          Divider(color: AppColors.surfaceVar, height: 1),
          child,
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconColor: AppColors.textSecondary,
      collapsedIconColor: AppColors.textSecondary,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          answer,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Çıkış Yap',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Hesabından çıkış yapmak istediğine emin misin?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(AppStrings.logout,
                style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.accent, size: 24),
            SizedBox(width: 10),
            Text('Hesabı Sil',
                style: TextStyle(color: AppColors.accent)),
          ],
        ),
        content: const Text(
          'Hesabını silersen tüm verilerin kalıcı olarak silinecek ve geri alınamayacak.\n\nBu işlemi onaylıyor musun?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              final err = await context.read<AuthProvider>().deleteAccount();
              if (context.mounted) {
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: AppColors.accent),
                  );
                  Navigator.pop(context);
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
            child: const Text('Evet, Sil',
                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
