// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/habit_card.dart';
import '../add_habit/add_habit_screen.dart';
import '../stats/stats_screen.dart';
import '../habits/my_habits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();

    // Uygulama açılınca bildirim kurulumunu yap
    Future.microtask(() async {
      final auth = context.read<AuthProvider>();

      // AuthProvider içinde yazdığın o izin ve token fonksiyonlarını çağırıyoruz
      await auth.requestNotificationPermissions();
      await auth.syncFCMToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context, user),
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _index,
        children: const [_HabitListPage(), StatsScreen()],
      ),
      bottomNavigationBar: _buildNav(),
      floatingActionButton: _index == 0 ? _buildFAB() : null,
    );
  }

  Widget _buildDrawer(BuildContext context, Map<String, dynamic>? user) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.surface),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: const Text("E",
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            accountName: Text(user?['username'] ?? 'Kullanıcı',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?['email'] ?? 'email@example.com',
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.primary),
            title: const Text('Alışkanlıklarım'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyHabitsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded,
                color: AppColors.secondary),
            title: const Text('Profilim'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary),
            title: const Text('Ayarlar'),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Divider(color: AppColors.surfaceVar, indent: 20, endIndent: 20),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.accent),
            title: const Text('Çıkış Yap',
                style: TextStyle(
                    color: AppColors.accent, fontWeight: FontWeight.w600)),
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNav() => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceVar)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: 'İstatistik'),
          ],
        ),
      );

  Widget _buildFAB() => Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async => await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddHabitScreen())),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      );
}

class _HabitListPage extends StatelessWidget {
  const _HabitListPage();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final user = context.read<AuthProvider>().user;
    final stats = provider.stats;

    return SafeArea(
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Merhaba, ${user?['username'] ?? 'Emirhan'} 👋',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const Text("Hadi bugün zinciri kırma!",
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),

                const SizedBox(height: 24),
                _buildWeeklyCalendar(),

                const SizedBox(height: 24),
                // YENİ ROZET SATIRI
                _buildBadgeRow(stats, provider.habits),

                const SizedBox(height: 32),
                const Text("Günün Alışkanlıkları",
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        if (provider.isLoading)
          const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()))
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HabitCard(habit: provider.habits[i]),
              ),
              childCount: provider.habits.length,
            )),
          ),
      ]),
    );
  }

  Widget _buildWeeklyCalendar() {
    final now = DateTime.now();
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = now.add(Duration(days: index - 3));
          final isToday = index == 3;

          return Container(
            width: 55,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isToday ? AppColors.primary : AppColors.surfaceVar),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    [
                      "Pzt",
                      "Sal",
                      "Çar",
                      "Per",
                      "Cum",
                      "Cmt",
                      "Paz"
                    ][day.weekday - 1],
                    style: TextStyle(
                        color:
                            isToday ? Colors.white70 : AppColors.textSecondary,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text("${day.day}",
                    style: TextStyle(
                        color: isToday ? Colors.white : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgeRow(StatsModel? stats, List<HabitModel> habits) {
    int completedToday = 0;
    for (var habit in habits) {
      if (habit.todayLogId != null) completedToday++;
    }
    final int total = habits.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Arayı açalım
      children: [
        _badgeItem("💎", "$completedToday/$total", "Bugün"),
        _badgeItem(
            "⚡",
            total > 0 ? "%${((completedToday / total) * 100).toInt()}" : "%0",
            "Verim"),
        _badgeItem("🏆", "Global", "Rütbe"), // Seri artık burada değil
      ],
    );
  }

  Widget _badgeItem(String icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}
