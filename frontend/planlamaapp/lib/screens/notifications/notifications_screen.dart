// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/habit_provider.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _globalNotifications = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HabitProvider>().loadHabits());
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.notifTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Genel Bildirim Toggle ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.primary.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_active_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bildirimleri Aç',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hatırlatıcılar için bildirimleri aktif et',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _globalNotifications,
                    onChanged: (v) => setState(() => _globalNotifications = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Alışkanlık Hatırlatıcıları Başlık ──
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.alarm_rounded,
                      color: AppColors.warning, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Alışkanlık Hatırlatıcıları',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Her alışkanlık için ayrı hatırlatıcı saati belirle',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ── Alışkanlık Listesi ──
            if (habits.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.surfaceVar),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Text('📭', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 12),
                      Text(
                        'Henüz alışkanlık yok',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...habits.map((habit) => _buildHabitReminderCard(habit)),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitReminderCard(HabitModel habit) {
    final hasReminder = habit.reminderHour >= 0;
    final timeStr = hasReminder
        ? '${habit.reminderHour.toString().padLeft(2, '0')}:${habit.reminderMinute.toString().padLeft(2, '0')}'
        : AppStrings.noReminder;

    final color = _hexColor(habit.colorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasReminder
              ? color.withOpacity(0.3)
              : AppColors.surfaceVar,
        ),
      ),
      child: Row(
        children: [
          // İkon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(habit.iconEmoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),

          // Başlık ve Saat
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
                    Icon(
                      hasReminder ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                      size: 14,
                      color: hasReminder ? AppColors.success : AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: hasReminder ? AppColors.success : AppColors.textHint,
                        fontSize: 13,
                        fontWeight: hasReminder ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Saat Ayarla Butonu
          GestureDetector(
            onTap: () => _pickTime(context, habit),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: hasReminder ? null : AppColors.primaryGradient,
                color: hasReminder ? AppColors.surfaceVar : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                hasReminder ? 'Değiştir' : 'Ayarla',
                style: TextStyle(
                  color: hasReminder ? AppColors.textSecondary : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Kaldır butonu (sadece ayarlanmışsa)
          if (hasReminder) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeReminder(habit),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.accent, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, HabitModel habit) async {
    final initialTime = habit.reminderHour >= 0
        ? TimeOfDay(hour: habit.reminderHour, minute: habit.reminderMinute)
        : TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      try {
        await apiService.updateHabit(habit.id, {
          'reminder_hour': picked.hour,
          'reminder_minute': picked.minute,
        });
        if (mounted) {
          context.read<HabitProvider>().loadHabits();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${habit.iconEmoji} ${habit.title} için hatırlatıcı ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} olarak ayarlandı',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeReminder(HabitModel habit) async {
    try {
      await apiService.updateHabit(habit.id, {
        'reminder_hour': -1,
        'reminder_minute': 0,
      });
      if (mounted) {
        context.read<HabitProvider>().loadHabits();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${habit.iconEmoji} ${habit.title} hatırlatıcısı kaldırıldı'),
            backgroundColor: AppColors.surfaceVar,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.accent),
        );
      }
    }
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
