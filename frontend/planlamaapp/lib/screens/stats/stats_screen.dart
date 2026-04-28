// lib/screens/stats/stats_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/habit_provider.dart';
import './habit_individual_stats_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HabitProvider>().loadHabits();
      context.read<HabitProvider>().loadStats();
    });
  }

  Future<void> _refresh() async {
    await context.read<HabitProvider>().loadHabits();
    await context.read<HabitProvider>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;
    final stats = context.watch<HabitProvider>().stats;

    // Hesaplamalar
    int completedToday = 0;
    for (var h in habits) {
      if (h.todayLogId != null) completedToday++;
    }
    final total = habits.length;
    final progress = total > 0 ? completedToday / total : 0.0;
    int bestStreak = 0;
    for (var h in habits) {
      if (h.streak > bestStreak) bestStreak = h.streak;
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Başlık ──
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  "İstatistikler 📊",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // ── Özet Kartları ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        '🎯',
                        '$completedToday/$total',
                        'Bugün',
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        '⚡',
                        total > 0
                            ? '%${(progress * 100).toInt()}'
                            : '%0',
                        'Verim',
                        AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        '🔥',
                        '$bestStreak',
                        'En Uzun Seri',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        '📋',
                        '$total',
                        'Toplam Alışkanlık',
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Günlük İlerleme Ring ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surface,
                        AppColors.primary.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Günlük İlerleme',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CustomPaint(
                          painter: _ProgressRingPainter(progress: progress),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '$completedToday / $total',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Haftalık Grafik ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceVar),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Haftalık Tamamlanma',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 160,
                        child: _buildWeeklyChart(stats),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Alışkanlık Detay Listesi Başlık ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.list_rounded,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Detaylı İstatistikler',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Alışkanlık Liste ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = habits[index];
                    final color = _hexColor(habit.colorHex);
                    final isDone = context.watch<HabitProvider>().isCompleted(habit.id);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HabitIndividualStatsScreen(habit: habit),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDone
                                ? AppColors.success.withOpacity(0.4)
                                : AppColors.surfaceVar,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(habit.iconEmoji,
                                    style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text('🔥 ',
                                          style: TextStyle(fontSize: 12)),
                                      Text(
                                        '${habit.streak} gün seri',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        isDone
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked,
                                        size: 14,
                                        color: isDone
                                            ? AppColors.success
                                            : AppColors.textHint,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isDone ? 'Tamamlandı' : 'Bekliyor',
                                        style: TextStyle(
                                          color: isDone
                                              ? AppColors.success
                                              : AppColors.textHint,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textSecondary, size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: habits.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(StatsModel? stats) {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    if (stats == null || stats.weeklyCompletion.isEmpty) {
      return const Center(
        child: Text('Veri yükleniyor...',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final maxCount = stats.weeklyCompletion.fold<int>(
        1, (prev, e) => max(prev, (e['count'] as int? ?? 0)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final count = i < stats.weeklyCompletion.length
            ? (stats.weeklyCompletion[i]['count'] as int? ?? 0)
            : 0;
        final height = maxCount > 0 ? (count / maxCount) * 110 : 0.0;
        final isToday = i == stats.weeklyCompletion.length - 1;

        // Tarihten gün adı
        String dayLabel = '';
        if (i < stats.weeklyCompletion.length) {
          try {
            final d = DateTime.parse(stats.weeklyCompletion[i]['date']);
            dayLabel = days[d.weekday - 1];
          } catch (_) {
            dayLabel = '${i + 1}';
          }
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    color: isToday ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  height: max(height, 8),
                  decoration: BoxDecoration(
                    gradient: isToday
                        ? AppColors.primaryGradient
                        : LinearGradient(
                            colors: [
                              AppColors.surfaceVar,
                              AppColors.surfaceVar.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dayLabel,
                  style: TextStyle(
                    color: isToday ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 14) / 2;

    // Background ring
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.surfaceVar
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..shader = AppColors.primaryGradient
              .createShader(Rect.fromCircle(center: c, radius: r))
          ..strokeWidth = 14
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress;
}