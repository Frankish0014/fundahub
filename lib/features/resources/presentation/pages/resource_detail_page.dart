import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';

class ResourceDetailPage extends StatelessWidget {
  const ResourceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
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
                  'Education',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.interestChipText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '5 min read',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Grant Writing for Beginners',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.avatarBg,
                child: Text('S'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By Sarah Mensah',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Strategic Funding Advisor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.laptop_mac,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Winning grants starts with clarity. Before you draft a single sentence, align your venture story with what funders actually evaluate.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          Text(
            'Read the Guidelines Twice',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Most rejections come from eligibility misses, not weak ideas. Highlight deadlines, ownership rules, and required documents first.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Define Your Impact',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Funders fund outcomes. Quantify who benefits, how you measure success, and what changes in 12 months.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'The Budget is Your Roadmap',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Every line item should map to an activity in your plan. Vague budgets signal weak execution.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.quoteBg,
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: AppColors.quoteAccent, width: 4),
              ),
            ),
            child: Text(
              '"A successful proposal doesn\'t just show you need the money; it proves you are the most capable steward of the donor\'s mission."',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Ready to Apply?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.verifiedBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.verified,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'VERIFIED',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.verified,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.deadline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '14 days left',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.deadline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.bookmark_border, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Agri-Tech Innovation Grant 2024',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Up to \$25,000 in seed funding for smallholder solutions.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['Agriculture', 'Seed Funding']
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.interestChipBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            t,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.interestChipText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                FhPrimaryButton(
                  label: 'View Opportunity',
                  showTrailingChevron: true,
                  onPressed: () => context.go('/home/search'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Explore More Education Resources'),
            ),
          ),
        ],
      ),
    );
  }
}
