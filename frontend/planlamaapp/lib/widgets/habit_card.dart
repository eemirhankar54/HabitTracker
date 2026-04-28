// lib/widgets/habit_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/habit_provider.dart';
import '../screens/habit_detail/habit_detail_screen.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  const HabitCard({super.key, required this.habit});

  Color _getHexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _getHexColor(habit.colorHex);
    final isDone = context.watch<HabitProvider>().isCompleted(habit.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isDone
                  ? AppColors.success.withOpacity(0.5)
                  : AppColors.surfaceVar,
              width: 1.5),
        ),
        child: Row(
          children: [
            // İkon Alanı
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(habit.iconEmoji,
                      style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),

            // Başlık
            Expanded(
              child: Text(
                habit.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // YENİ: Seri (Streak) Göstergesi
            if (habit.streak > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("🔥", style: TextStyle(fontSize: 16)),
                    Text(
                      "${habit.streak}",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

            // Çöp Kutusu
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.accent, size: 22),
              onPressed: () => _confirmDelete(context),
            ),

            // Detay İşareti
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 26),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title:
            const Text('Sil', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
            '\"${habit.title}\" alışkanlığını silmek istediğine emin misin?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          TextButton(
            onPressed: () {
              context.read<HabitProvider>().deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
