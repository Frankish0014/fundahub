import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';

class SavedEmptyView extends StatelessWidget {
  const SavedEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 2),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bookmark_border,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 18,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No saved opportunities yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start exploring and bookmark what fits you to keep track of your growth journey.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          FhPrimaryButton(
            label: 'Search Opportunities',
            onPressed: () => context.go('/home/search'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              'View Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
