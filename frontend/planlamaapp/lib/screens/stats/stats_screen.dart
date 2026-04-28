import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/habit_provider.dart';
import './habit_individual_stats_screen.dart'; // Yeni oluşturacağımız sayfa

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "Alışkanlık Performansı",
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final habit = habits[index];
                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Text(habit.iconEmoji, style: const TextStyle(fontSize: 24)),
                      title: Text(habit.title, style: const TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Yeni pencereye (sayfaya) gidiyoruz
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HabitIndividualStatsScreen(habit: habit),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: habits.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}