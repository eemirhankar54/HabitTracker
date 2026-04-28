// lib/providers/habit_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HabitModel {
  final int id;
  final String title;
  final String description;
  final String iconEmoji;
  final String colorHex;
  final int targetDaysPerWeek;
  final int streak;
  final int? todayLogId;

  HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.colorHex,
    required this.targetDaysPerWeek,
    required this.streak,
    this.todayLogId,
  });

  factory HabitModel.fromJson(Map<String, dynamic> j) => HabitModel(
        id: j['id'] as int,
        title: j['title'] as String,
        description: j['description'] as String? ?? '',
        iconEmoji: j['icon_emoji'] as String? ?? '⭐',
        colorHex: j['color_hex'] as String? ?? '#6C63FF',
        targetDaysPerWeek: j['target_days_per_week'] as int? ?? 7,
        streak: j['streak'] as int? ?? 0,
        todayLogId: j['today_log_id'] as int?,
      );
}

class StatsModel {
  final int totalHabits;
  final int todayCompleted;
  final int todayTotal;
  final double todayProgress;
  final List<Map<String, dynamic>> weeklyCompletion;
  final int longestStreak;

  StatsModel({
    required this.totalHabits,
    required this.todayCompleted,
    required this.todayTotal,
    required this.todayProgress,
    required this.weeklyCompletion,
    required this.longestStreak,
  });

  factory StatsModel.fromJson(Map<String, dynamic> j) => StatsModel(
        totalHabits: j['total_habits'] as int,
        todayCompleted: j['today_completed'] as int,
        todayTotal: j['today_total'] as int,
        todayProgress: (j['today_progress'] as num).toDouble(),
        weeklyCompletion: (j['weekly_completion'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
        longestStreak: j['longest_streak'] as int,
      );
}

class HabitProvider extends ChangeNotifier {
  List<HabitModel> _habits = [];
  StatsModel? _stats;
  bool _isLoading = false;
  final Map<int, int> _todayLogIds = {}; // habitId → logId

  List<HabitModel> get habits => _habits;
  StatsModel? get stats => _stats;
  bool get isLoading => _isLoading;

  bool isCompleted(int habitId) => _todayLogIds.containsKey(habitId);

  bool checkIfDateIsCompleted(int habitId, DateTime date) {
    // Bugün ise mevcut map'ten kontrol et
    if (DateUtils.isSameDay(date, DateTime.now())) {
      return _todayLogIds.containsKey(habitId);
    }
    return false;
  }

// habit_provider.dart içindeki loadHabits
  Future<void> loadHabits() async {
    _setLoading(true);
    try {
      final List<dynamic> data = await apiService.getHabits();
      _habits = data.map((j) => HabitModel.fromJson(j)).toList();

      // Senkronizasyon burada gerçekleşiyor:
      _todayLogIds.clear(); // Listeyi tazele
      for (var habit in _habits) {
        if (habit.todayLogId != null) {
          _todayLogIds[habit.id] = habit.todayLogId!;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Yükleme hatası: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStats() async {
    try {
      final data = await apiService.getStats();
      _stats = StatsModel.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  Future<String?> addHabit({
    required String title,
    String description = '',
    String iconEmoji = '⭐',
    String colorHex = '#6C63FF',
    int targetDays = 30,
  }) async {
    try {
      await apiService.createHabit({
        'title': title,
        'description': description,
        'icon_emoji': iconEmoji,
        'color_hex': colorHex,
        'target_days_per_week': targetDays.toInt(),
        'reminder_hour': -1,
        'reminder_minute': 0,
      });
      await loadHabits();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await apiService.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      _todayLogIds.remove(id);
      notifyListeners();
    } catch (_) {}
  }

  // lib/providers/habit_provider.dart

  Future<void> toggleHabit(int habitId) async {
    try {
      if (isCompleted(habitId)) {
        final logId = _todayLogIds[habitId]!;
        await apiService.unlogHabit(logId);
        _todayLogIds.remove(habitId);
      } else {
        final data = await apiService.logHabit(habitId);
        _todayLogIds[habitId] = data['id'] as int;
      }
      await loadHabits();
      await loadStats();
      notifyListeners();
    } catch (e) {
      // 409 aldıysak senkronizasyon bozulmuştur, verileri baştan çek
      await loadHabits();
      await loadStats();
    }
  }
// lib/providers/habit_provider.dart içine ekle

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
