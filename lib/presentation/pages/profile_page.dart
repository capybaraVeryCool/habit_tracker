import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habeats/presentation/blocs/auth/auth_bloc.dart';
import 'package:habeats/presentation/blocs/habit/habit_bloc.dart';
import 'package:habeats/presentation/blocs/theme/theme_bloc.dart';
import 'package:habeats/routes/router.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) return const SizedBox.shrink();

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 32,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: isSmallScreen ? 50 : 70,
                              backgroundColor:
                                  theme.colorScheme.tertiaryFixedDim,
                              child: Text(
                                user.displayName[0].toUpperCase(),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: isSmallScreen ? 32 : 48,
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            Text(
                              user.displayName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: isSmallScreen ? 24 : 32,
                              ),
                            ),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.textTheme.bodyLarge?.color
                                    ?.withOpacity(0.7),
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    BlocBuilder<HabitBloc, HabitState>(
                      builder: (context, habitState) {
                        final totalXP = habitState.habits.fold<int>(
                          0,
                          (sum, habit) => sum + habit.xp,
                        );
                        final level = (totalXP / 100).floor() + 1;

                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.military_tech),
                                title: const Text('Level'),
                                trailing: Text(
                                  level.toString(),
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.star),
                                title: const Text('Total XP'),
                                trailing: Text(
                                  totalXP.toString(),
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.format_list_bulleted),
                                title: const Text('Active Habits'),
                                trailing: Text(
                                  habitState.habits.length.toString(),
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appearance',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<ThemeBloc, ThemeState>(
                              builder: (context, state) {
                                return SwitchListTile(
                                  activeTrackColor:
                                      theme.colorScheme.tertiaryFixedDim,
                                  activeColor:
                                      theme.colorScheme.onTertiaryFixedVariant,
                                  title: Row(
                                    children: [
                                      Icon(
                                        state.isDarkMode
                                            ? Icons.dark_mode
                                            : Icons.light_mode,
                                        color:
                                            theme.colorScheme.tertiaryFixedDim,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        state.isDarkMode
                                            ? 'Dark Mode'
                                            : 'Light Mode',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  value: state.isDarkMode,
                                  onChanged: (value) {
                                    context
                                        .read<ThemeBloc>()
                                        .add(ThemeChanged(value));
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        AutoRouter.of(context).replace(const LoginRoute());
                      },
                      icon:
                          Icon(Icons.logout, color: theme.colorScheme.tertiary),
                      label: Text(
                        'Sign Out',
                        style: TextStyle(color: theme.colorScheme.tertiary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
