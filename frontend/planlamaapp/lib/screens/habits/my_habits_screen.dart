// lib/screens/habits/my_habits_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/habit_card.dart';
import '../add_habit/add_habit_screen.dart';

class MyHabitsScreen extends StatelessWidget {
  const MyHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Alışkanlıkları provider'dan dinliyoruz
    final habits = context.watch<HabitProvider>().habits;

    return Scaffold(
      backgroundColor: AppColors.background, //
      appBar: AppBar(
        title: const Text('Alışkanlıklarım'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddHabitScreen()),
            ),
          ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(child: Text("Henüz bir alışkanlık eklemedin."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: habits.length,
              itemBuilder: (context, index) => HabitCard(habit: habits[index]),
            ),
    );
  }
}