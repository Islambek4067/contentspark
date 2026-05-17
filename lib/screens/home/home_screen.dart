import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../models/script_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scripts_provider.dart';
import '../auth/login_screen.dart';
import '../generate/generate_screen.dart';
import '../profile/profile_screen.dart';
import '../script/script_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Your Scripts' : 'Profile'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _ScriptsList(userId: user.uid),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GenerateScreen()),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Scripts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ScriptsList extends StatelessWidget {
  const _ScriptsList({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final scriptsProvider = context.read<ScriptsProvider>();
    return StreamBuilder<List<ScriptModel>>(
      stream: scriptsProvider.scriptsForUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load scripts',
            message: snapshot.error.toString(),
          );
        }

        final scripts = snapshot.data ?? [];
        if (scripts.isEmpty) {
          return const _EmptyState(
            icon: Icons.history_edu_outlined,
            title: 'No scripts yet',
            message: 'Tap Generate to create your first video script.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: scripts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final script = scripts[index];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScriptDetailScreen(script: script),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                script.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.dark,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PlatformChip(platform: script.platform),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          script.hook,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatDate(script.createdAt),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
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
      },
    );
  }

  static String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$mm/$dd/${date.year}';
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        platform,
        style: const TextStyle(
          color: AppColors.dark,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
