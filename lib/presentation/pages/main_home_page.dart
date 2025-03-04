import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habeats/presentation/blocs/auth/auth_bloc.dart';
import 'package:habeats/presentation/blocs/habit/habit_bloc.dart';
import 'package:habeats/presentation/widgets/add_habit_dialog.dart';
import 'package:habeats/routes/router.dart';
import 'package:habeats/presentation/widgets/habit_summary_card.dart';
import 'package:habeats/presentation/widgets/stats_overview.dart';

@RoutePage()
class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<HabitBloc>().add(LoadHabits(user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            floating: true,
            pinned: true,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icon/icon.jpg',
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Habit Tracker'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () =>
                    AutoRouter.of(context).push(const ProfileRoute()),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 800,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.displayName ?? 'User'}!',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your progress and build better habits',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? double.infinity : 800,
              ),
              child: const StatsOverview(),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 1200,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Habits',
                        style: theme.textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () => context.pushRoute(const HabitsRoute()),
                        icon: Icon(
                          Icons.visibility,
                          color: theme.colorScheme.tertiary,
                        ),
                        label: Text(
                          'View All',
                          style: TextStyle(color: theme.colorScheme.tertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<HabitBloc, HabitState>(
            builder: (context, state) {
              if (state.status == HabitStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.habits.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icon/icon.jpg',
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 24),
                          Icon(
                            Icons.note_add,
                            size: 64,
                            color: theme.colorScheme.tertiaryFixed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No habits yet',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first habit to get started',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                theme.colorScheme.tertiaryFixed,
                              ),
                            ),
                            onPressed: () => _showAddHabitDialog(context),
                            icon: Icon(
                              Icons.add,
                              color: theme.colorScheme.onTertiaryFixedVariant,
                            ),
                            label: Text(
                              'Add Habit',
                              style: TextStyle(
                                  color:
                                      theme.colorScheme.onTertiaryFixedVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? double.infinity : 1200,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isSmallScreen ? 1 : 3,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: state.habits.length.clamp(0, 3),
                        itemBuilder: (context, index) {
                          final habit = state.habits[index];
                          return HabitSummaryCard(habit: habit);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 1200,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionsGrid(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.tertiaryFixed,
        onPressed: () => _showAddHabitDialog(context),
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onTertiaryFixedVariant,
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: 1,
      itemBuilder: (context, index) {
        return _buildQuickActionCard(
          context,
          icon: Icons.emoji_events,
          title: 'Achievements',
          subtitle: 'Track your progress',
          onTap: () => AutoRouter.of(context).push(const AchievementsRoute()),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.tertiaryFixedDim),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      showDialog(
        context: context,
        builder: (context) => AddHabitDialog(userId: user.id),
      );
    }
  }
}
