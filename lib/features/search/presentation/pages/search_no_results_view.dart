import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Search_No_Results — shown when a query/filter returns nothing.
class SearchNoResultsView extends StatelessWidget {
  const SearchNoResultsView({
    super.key,
    required this.query,
    required this.onClearFilters,
    required this.onBrowseAll,
    this.onPopularTap,
  });

  final String query;
  final VoidCallback onClearFilters;
  final VoidCallback onBrowseAll;
  final ValueChanged<String>? onPopularTap;

  String get _shortQuery {
    final q = query.trim();
    if (q.length <= 22) return q;
    return '${q.substring(0, 22)}...';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.search, size: 48, color: AppColors.primary),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Icon(Icons.cancel, size: 20, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            children: [
              const TextSpan(text: 'No results found for "'),
              TextSpan(
                text: _shortQuery.isEmpty ? 'your search' : _shortQuery,
                style: const TextStyle(color: Color(0xFF8B6B2B)),
              ),
              const TextSpan(text: '"'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "Try different keywords or filters to find what you're looking for.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: onBrowseAll,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.borderStrong),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Browse All Opportunities'),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Popular Searches',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PopularCard(
                icon: Icons.payments_outlined,
                title: 'Grants',
                subtitle: 'Funding for ventures',
                onTap: () {
                  if (onPopularTap != null) {
                    onPopularTap!('Grants');
                  } else {
                    onBrowseAll();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PopularCard(
                icon: Icons.rocket_launch_outlined,
                title: 'Accelerators',
                subtitle: 'Programs & mentorship',
                onTap: () {
                  if (onPopularTap != null) {
                    onPopularTap!('Accelerators');
                  } else {
                    onBrowseAll();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF8B6B2B)),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
