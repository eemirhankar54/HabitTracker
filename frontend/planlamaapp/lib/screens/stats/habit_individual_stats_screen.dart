// lib/screens/stats/habit_individual_stats_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/habit_provider.dart';

class HabitIndividualStatsScreen extends StatelessWidget {
  final HabitModel habit;

  const HabitIndividualStatsScreen({super.key, required this.habit});

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final currentHabit = habitProvider.habits
        .firstWhere((h) => h.id == habit.id, orElse: () => habit);
    final bool isDoneToday = habitProvider.isCompleted(currentHabit.id);
    final int displayStreak = currentHabit.streak;
    int weeklyScore = displayStreak > 7 ? 7 : displayStreak;
    final color = _hexColor(currentHabit.colorHex);
    final weeklyProgress = weeklyScore / 7;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(currentHabit.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            // ── Üst Başlık Kartı ──
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Column(
                children: [
                  // Emoji büyük
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(currentHabit.iconEmoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentHabit.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (currentHabit.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      currentHabit.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Bugünkü durum badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDoneToday
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDoneToday
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.accent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDoneToday
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 18,
                          color: isDoneToday
                              ? AppColors.success
                              : AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDoneToday
                              ? 'Bugün Tamamlandı ✅'
                              : 'Bugün Henüz Yapılmadı',
                          style: TextStyle(
                            color: isDoneToday
                                ? AppColors.success
                                : AppColors.accent,
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
            const SizedBox(height: 20),

            // ── İstatistik Kartları Grid ──
            Row(
              children: [
                Expanded(
                  child: _miniStatCard(
                    '🔥',
                    '$displayStreak',
                    'Günlük Seri',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniStatCard(
                    '📅',
                    '$weeklyScore/7',
                    'Bu Hafta',
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _miniStatCard(
                    '🎯',
                    '${currentHabit.targetDaysPerWeek}',
                    'Hedef Gün',
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniStatCard(
                    '⚡',
                    '${(weeklyProgress * 100).toInt()}%',
                    'Haftalık Verim',
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Haftalık İlerleme Ring ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceVar),
              ),
              child: Column(
                children: [
                  const Text(
                    'Haftalık İlerleme',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: weeklyProgress,
                        color: color,
                      ),
                      child: Center(
                        child: Text(
                          '$weeklyScore/7',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Hafta günleri dot row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(7, (i) {
                      final filled = i < weeklyScore;
                      return Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: filled
                              ? color.withOpacity(0.8)
                              : AppColors.surfaceVar,
                          shape: BoxShape.circle,
                        ),
                        child: filled
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Bildirim Durumu ──
            Container(
              padding: const EdgeInsets.all(18),
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
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.alarm_rounded,
                        color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hatırlatıcı',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          currentHabit.reminderHour >= 0
                              ? '${currentHabit.reminderHour.toString().padLeft(2, '0')}:${currentHabit.reminderMinute.toString().padLeft(2, '0')}'
                              : 'Ayarlanmadı',
                          style: TextStyle(
                            color: currentHabit.reminderHour >= 0
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStatCard(
      String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 12) / 2;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.surfaceVar
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 12
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
