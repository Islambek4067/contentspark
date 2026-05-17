import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final profile = auth.profile;
    final name = profile?.name ?? user?.displayName ?? 'Creator';
    final email = profile?.email ?? user?.email ?? '';
    final avatarUrl = profile?.avatarUrl ?? user?.photoURL ?? '';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primary,
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.dark,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: 14),
                        _VerificationPill(
                          verified: user?.emailVerified ?? false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          await context.read<AuthProvider>().signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              LoginScreen.routeName,
                              (_) => false,
                            );
                          }
                        },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationPill extends StatelessWidget {
  const _VerificationPill({required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (verified ? AppColors.success : AppColors.accent).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified
                ? Icons.verified_outlined
                : Icons.mark_email_unread_outlined,
            size: 18,
            color: verified ? AppColors.success : AppColors.dark,
          ),
          const SizedBox(width: 8),
          Text(
            verified ? 'Email verified' : 'Verification email sent',
            style: TextStyle(
              color: verified ? AppColors.success : AppColors.dark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
