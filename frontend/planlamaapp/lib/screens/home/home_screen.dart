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
import '../profile/profile_screen.dart';
import '../about/about_screen.dart';
import '../notifications/notifications_screen.dart';

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

    Future.microtask(() async {
      final auth = context.read<AuthProvider>();
      await auth.requestNotificationPermissions();
      await auth.syncFCMToken();
      await auth.fetchProfile();

      if (mounted) {
        await context.read<HabitProvider>().loadHabits();
        await context.read<HabitProvider>().loadStats();
      }
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
        children: const [
          _HabitListPage(),
          _MyHabitsTab(),
          StatsScreen(),
        ],
      ),
      bottomNavigationBar: _buildNav(),
      floatingActionButton: _index == 1 ? _buildFAB() : null,
    );
  }

  // ── DRAWER ──────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context, Map<String, dynamic>? user) {
    final username = user?['username'] ?? 'Kullanıcı';
    final email = user?['email'] ?? 'email@example.com';

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          // ── Profil Başlığı ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Menü Öğeleri ──
          _drawerItem(
            icon: Icons.home_rounded,
            color: AppColors.primary,
            label: 'Ana Sayfa',
            onTap: () {
              Navigator.pop(context);
              setState(() => _index = 0);
            },
          ),
          _drawerItem(
            icon: Icons.checklist_rounded,
            color: AppColors.success,
            label: AppStrings.myHabits,
            onTap: () {
              Navigator.pop(context);
              setState(() => _index = 1);
            },
          ),
          _drawerItem(
            icon: Icons.bar_chart_rounded,
            color: AppColors.secondary,
            label: AppStrings.statistics,
            onTap: () {
              Navigator.pop(context);
              setState(() => _index = 2);
            },
          ),

          Divider(
            color: AppColors.surfaceVar,
            indent: 24,
            endIndent: 24,
            height: 24,
          ),

          _drawerItem(
            icon: Icons.person_rounded,
            color: const Color(0xFFE879F9),
            label: AppStrings.profile,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          _drawerItem(
            icon: Icons.notifications_rounded,
            color: AppColors.warning,
            label: AppStrings.notifications,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()));
            },
          ),
          _drawerItem(
            icon: Icons.info_rounded,
            color: AppColors.secondary,
            label: AppStrings.about,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()));
            },
          ),

          const Spacer(),

          // ── Çıkış ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: AppColors.surfaceVar, height: 1),
          ),
          _drawerItem(
            icon: Icons.logout_rounded,
            color: AppColors.accent,
            label: AppStrings.logout,
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        hoverColor: color.withOpacity(0.05),
        splashColor: color.withOpacity(0.1),
      ),
    );
  }

  // ── BOTTOM NAV ──────────────────────────────────────────
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
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
            BottomNavigationBarItem(
                icon: Icon(Icons.checklist_rounded), label: 'Alışkanlıklar'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: 'İstatistik'),
          ],
        ),
      );

  // ── FAB (Sadece Alışkanlıklarım sekmesinde) ──
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
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddHabitScreen()));
            if (mounted) {
              context.read<HabitProvider>().loadHabits();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      );
}

// ══════════════════════════════════════════════════════════
// ANA SAYFA TAB'I
// ══════════════════════════════════════════════════════════

class _HabitListPage extends StatefulWidget {
  const _HabitListPage();

  @override
  State<_HabitListPage> createState() => _HabitListPageState();
}

class _HabitListPageState extends State<_HabitListPage> {
  Future<void> _refresh() async {
    await context.read<HabitProvider>().loadHabits();
    await context.read<HabitProvider>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final user = context.read<AuthProvider>().user;
    final stats = provider.stats;

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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Merhaba, ${user?['username'] ?? 'Kullanıcı'} 👋',
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
            else if (provider.habits.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📭', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.noHabits,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Alışkanlıklar sekmesinden ekle',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HabitCard(habit: provider.habits[i]),
                  ),
                  childCount: provider.habits.length,
                )),
              ),
          ],
        ),
      ),
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _badgeItem("💎", "$completedToday/$total", "Bugün"),
        _badgeItem(
            "⚡",
            total > 0
                ? "%${((completedToday / total) * 100).toInt()}"
                : "%0",
            "Verim"),
        _badgeItem("🏆", "Global", "Rütbe"),
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
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// ALIŞKANLIKLARIM TAB'I
// ══════════════════════════════════════════════════════════

class _MyHabitsTab extends StatefulWidget {
  const _MyHabitsTab();

  @override
  State<_MyHabitsTab> createState() => _MyHabitsTabState();
}

class _MyHabitsTabState extends State<_MyHabitsTab> {
  Future<void> _refresh() async {
    await context.read<HabitProvider>().loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: habits.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📝', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 16),
                          Text(
                            'Henüz alışkanlık eklemedin',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '+ butonuna bas ve ilk alışkanlığını ekle!',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Text(
                        'Alışkanlıklarım',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HabitCard(habit: habits[i]),
                        ),
                        childCount: habits.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
      ),
    );
  }
}
