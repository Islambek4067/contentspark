import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/strings.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.showText = true});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: size * 0.48,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.dark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.tagline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
