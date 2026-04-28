import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/habit_provider.dart';

class HabitIndividualStatsScreen extends StatelessWidget {
  final HabitModel habit;

  const HabitIndividualStatsScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    // Provider'ı dinliyoruz ki değişim anında ekran yenilensin
    final habitProvider = context.watch<HabitProvider>();
    final currentHabit = habitProvider.habits
        .firstWhere((h) => h.id == habit.id, orElse: () => habit);
    // Bugün tamamlanmış mı?
    final bool isDoneToday = habitProvider.isCompleted(currentHabit.id);
    final int displayStreak = currentHabit.streak;
    
    int weeklyScore = displayStreak > 7 ? 7 : displayStreak;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(currentHabit.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(currentHabit.iconEmoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),

            // Haftalık İstatistik Kartı
            _statCard(
              "Bu Haftaki Durum",
              "$weeklyScore / 7", // İşareti kaldırınca burası artık güncellenecek
              Icons.calendar_view_week,
              AppColors.primary,
            ),
            const SizedBox(height: 16),

            // Seri (Streak) Kartı
            _statCard(
              "Güncel Seri",
              "$displayStreak Gün",
              Icons.local_fire_department,
              Colors.orange,
            ),
            const SizedBox(height: 16),

            // Bugünün Durumu Kartı
            _statCard(
              "Bugün Yapıldı mı?",
              isDoneToday ? "EVET ✅" : "HAYIR ❌",
              Icons.today,
              isDoneToday ? AppColors.success : AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVar),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
