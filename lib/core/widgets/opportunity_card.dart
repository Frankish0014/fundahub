import 'package:flutter/material.dart';

import '../../features/opportunities/domain/entities/opportunity.dart';
import '../theme/app_colors.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.width,
    this.onTap,
    this.dense = false,
  });

  final Opportunity opportunity;
  final double? width;
  final VoidCallback? onTap;

  /// Tighter spacing for fixed-height carousels (e.g. Home recommended).
  final bool dense;

  /// Safe carousel height across text-scale / narrow emulators.
  static double carouselHeight(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final base = shortest < 360 ? 200.0 : 216.0;
    return (base * textScale.clamp(1.0, 1.3)).clamp(200.0, 280.0);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pad = dense ? 12.0 : 14.0;
    final gapSm = dense ? 4.0 : 6.0;
    final gapMd = dense ? 8.0 : 10.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: dense ? double.infinity : null,
        padding: EdgeInsets.all(pad),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bounded =
                constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
              children: [
                _HeaderRow(opportunity: opportunity, textTheme: textTheme),
                SizedBox(height: gapMd),
                Text(
                  opportunity.typeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: gapSm),
                if (bounded)
                  Expanded(
                    child: _TitleBlock(
                      opportunity: opportunity,
                      textTheme: textTheme,
                    ),
                  )
                else
                  _TitleBlock(opportunity: opportunity, textTheme: textTheme),
                SizedBox(height: gapMd),
                _FooterRow(
                  opportunity: opportunity,
                  textTheme: textTheme,
                  dense: dense,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.opportunity, required this.textTheme});

  final Opportunity opportunity;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (opportunity.isVerified)
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.verifiedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: AppColors.verified,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'VERIFIED',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.verified,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
        Icon(Icons.access_time, size: 14, color: AppColors.deadline),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${opportunity.daysLeft} days left',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.deadline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.opportunity, required this.textTheme});

  final Opportunity opportunity;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          opportunity.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          opportunity.organization,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({
    required this.opportunity,
    required this.textTheme,
    required this.dense,
  });

  final Opportunity opportunity;
  final TextTheme textTheme;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amount',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                opportunity.amountLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              clipBehavior: Clip.hardEdge,
              children: opportunity.tags
                  .take(dense ? 2 : 3)
                  .map(
                    (tag) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: dense ? 8 : 10,
                        vertical: dense ? 3 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
