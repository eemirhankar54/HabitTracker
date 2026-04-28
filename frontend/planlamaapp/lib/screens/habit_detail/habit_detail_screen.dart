import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/habit_provider.dart';

class HabitDetailScreen extends StatelessWidget {
  final HabitModel habit;
  const HabitDetailScreen({super.key, required this.habit});

  // Gün isimlerini başladığı güne göre sıralayan yardımcı fonksiyon
  List<String> _getWeekDays(DateTime start) {
    final List<String> days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    // Perşembe ise (index 3), listeyi Per'den başlayacak şekilde döndürür
    int startIndex = start.weekday - 1;
    return List.generate(7, (index) => days[(startIndex + index) % 7]);
  }

  @override
  Widget build(BuildContext context) {
    // Başlangıç tarihi (Backend'den gelmeli, yoksa sabit)
    final DateTime startDate = DateTime(2026, 4, 23); // Örnek: Perşembe
    final DateTime today = DateTime.now();
    final weekDays = _getWeekDays(startDate);

    // Toplam hafta sayısını hesapla (Örn: 365 gün / 7)
    final int totalWeeks = (habit.targetDaysPerWeek / 7).ceil();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(habit.title)),
      body: Column(
        children: [
          // ÜST BAŞLIK: Gün İsimleri (Per, Cum, Cmt...)
          Padding(
            padding:
                const EdgeInsets.only(left: 80, right: 20, top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDays
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // TABLO GÖVDESİ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: totalWeeks,
              itemBuilder: (context, weekIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // SOL BAŞLIK: Hafta Sayısı
                      SizedBox(
                        width: 60,
                        child: Text(
                          "${weekIndex + 1}. Hafta",
                          style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),

                      // GÜN KUTUCUKLARI (1 Hafta / 7 Gün)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (dayIndex) {
                            final int totalDayIndex =
                                (weekIndex * 7) + dayIndex;

                            // Seçilen toplam hedef günü aşma
                            if (totalDayIndex >= habit.targetDaysPerWeek) {
                              return Expanded(child: const SizedBox());
                            }

                            final DateTime dayDate =
                                startDate.add(Duration(days: totalDayIndex));
                            final bool isToday =
                                DateUtils.isSameDay(dayDate, today);
                            final bool isLocked = dayDate.isAfter(today) ||
                                (dayDate.isBefore(today) && !isToday);

                            return Expanded(
                                child: _buildDayBox(
                                    context, dayDate, isToday, isLocked));
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// lib/screens/habit_detail/habit_detail_screen.dart içindeki ilgili metodlar

  // lib/screens/habit_detail/habit_detail_screen.dart içinde _buildDayBox kullanımı:

  Widget _buildDayBox(
      BuildContext context, DateTime dayDate, bool isToday, bool isLocked) {
    final bool isDone = context
        .watch<HabitProvider>()
        .checkIfDateIsCompleted(habit.id, dayDate);

    return GestureDetector(
      onTap: isLocked
          ? null
          : () => context.read<HabitProvider>().toggleHabit(habit.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 40,
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.success
              : AppColors.surface, // Veritabanında varsa yeşil
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday ? AppColors.primary : AppColors.surfaceVar,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Center(
          child: isDone
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : (isLocked
                  ? const Icon(Icons.lock_outline,
                      size: 14, color: AppColors.textHint)
                  : null),
        ),
      ),
    );
  }
}
