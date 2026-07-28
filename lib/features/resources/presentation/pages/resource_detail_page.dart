import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../domain/entities/training_resource.dart';

class ResourceDetailPage extends StatelessWidget {
  const ResourceDetailPage({super.key, this.resource});

  /// Selected resource, passed as router `extra` from the training hub.
  final TrainingResource? resource;

  @override
  Widget build(BuildContext context) {
    final r = resource;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('FundaHub'),
        centerTitle: true,
        actions: const [
          Icon(Icons.ios_share_outlined),
          SizedBox(width: 8),
          Icon(Icons.bookmark_border),
          SizedBox(width: 12),
        ],
      ),
      body: r == null
          ? const Center(child: Text('Resource not found.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.interestChipBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r.category,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.interestChipText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (r.readTime.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        r.readTime,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  r.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (r.author.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.avatarBg,
                        child: Text(r.author[0].toUpperCase()),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'By ${r.author}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (r.authorRole.isNotEmpty)
                            Text(
                              r.authorRole,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.laptop_mac,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                if (r.intro.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    r.intro,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
                ...r.sections.expand(
                  (s) => [
                    const SizedBox(height: 14),
                    Text(
                      s.heading,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                if (r.quote.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.quoteBg,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(
                          color: AppColors.quoteAccent,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      '"${r.quote}"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Explore More Resources'),
                  ),
                ),
                const SizedBox(height: 8),
                FhPrimaryButton(
                  label: 'Browse Opportunities',
                  showTrailingChevron: true,
                  onPressed: () => context.go('/home/search'),
                ),
              ],
            ),
    );
  }
}
