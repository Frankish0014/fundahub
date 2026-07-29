import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/usecases/opportunity_usecases.dart';
import '../bloc/opportunity_detail_bloc.dart';
import '../bloc/opportunity_detail_event.dart';
import '../bloc/opportunity_detail_state.dart';

class OpportunityDetailPage extends StatelessWidget {
  const OpportunityDetailPage({required this.opportunityId, super.key});

  final String opportunityId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OpportunityDetailBloc(
        getOpportunityById: sl<GetOpportunityById>(),
        toggleSavedOpportunity: sl<ToggleSavedOpportunity>(),
        getCurrentUser: sl(),
        getMyApplication: sl(),
      )..add(LoadOpportunityDetail(opportunityId)),
      child: const _OpportunityDetailView(),
    );
  }
}

class _OpportunityDetailView extends StatelessWidget {
  const _OpportunityDetailView();

  Widget _section(BuildContext context, String title, String body) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(s.opportunity),
        centerTitle: true,
      ),
      body: BlocBuilder<OpportunityDetailBloc, OpportunityDetailState>(
        builder: (context, state) {
          if (state.status == OpportunityDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == OpportunityDetailStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error'));
          }
          final o = state.opportunity;
          if (o == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'This opportunity is not available. It may still be awaiting admin verification.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final user = state.currentUser;
          final isProviderOwner =
              user != null &&
              user.isOpportunityProvider &&
              o.createdBy != null &&
              o.createdBy == user.id;
          final isEntrepreneur =
              user != null &&
              !user.isOpportunityProvider &&
              !user.isPlatformAdmin &&
              o.isPublic;
          final application = state.myApplication;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      o.typeLabel,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    o.daysLeft > 0 ? '${o.daysLeft} days left' : 'Closed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.deadline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                o.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                o.organization,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              if (o.location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  o.location,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 14),
              if (!o.isPublic ||
                  isProviderOwner ||
                  user?.isPlatformAdmin == true)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: switch (o.moderationStatus) {
                      ModerationStatus.rejected => const Color(0xFFFEF3F2),
                      ModerationStatus.pending => AppColors.deadlineBg,
                      ModerationStatus.approved => AppColors.mintSoft,
                    },
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    switch (o.moderationStatus) {
                      ModerationStatus.approved =>
                        'Verified by FundaHub admin — visible to entrepreneurs.',
                      ModerationStatus.rejected =>
                        'Rejected by admin${o.moderationNote.isEmpty ? '' : ': ${o.moderationNote}'}',
                      ModerationStatus.pending =>
                        'Pending admin review — not visible to entrepreneurs yet.',
                    },
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: switch (o.moderationStatus) {
                        ModerationStatus.rejected => AppColors.danger,
                        ModerationStatus.pending => AppColors.deadline,
                        ModerationStatus.approved => AppColors.verified,
                      },
                    ),
                  ),
                ),
              Text(
                o.amountLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.verified,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: o.tags
                    .map(
                      (t) => Chip(
                        label: Text(t),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(color: AppColors.border),
                        labelStyle: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              _section(context, 'About', o.description),
              _section(context, 'Target beneficiaries', o.targetBeneficiaries),
              _section(
                context,
                'Eligibility & conditions',
                o.eligibilityCriteria,
              ),
              if (o.requiredDocuments.isNotEmpty)
                _section(
                  context,
                  'Required documents',
                  o.requiredDocuments.map((d) => '• $d').join('\n'),
                ),
              _section(context, 'How to apply', o.applicationInstructions),
              if (o.contactEmail.isNotEmpty)
                _section(context, 'Contact', o.contactEmail),
              if (application != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your application: ${application.statusLabel}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (application.reviewerNote.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Provider note: ${application.reviewerNote}'),
                      ],
                    ],
                  ),
                ),
              ],
              if (isEntrepreneur) ...[
                if (application == null && o.isOpen)
                  FhPrimaryButton(
                    label: s.applyForOpportunity,
                    onPressed: () async {
                      final submitted = await context.push<bool>(
                        '/opportunities/${o.id}/apply',
                      );
                      if (submitted == true && context.mounted) {
                        context.read<OpportunityDetailBloc>().add(
                          LoadOpportunityDetail(o.id),
                        );
                      }
                    },
                  ),
                if (!o.isOpen && application == null)
                  const Text('Applications are closed for this opportunity.'),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.read<OpportunityDetailBloc>().add(
                    ToggleSaveOpportunity(o.id),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(o.isSaved ? s.unsave : s.saveForLater),
                ),
              ],
              if (isProviderOwner) ...[
                FhPrimaryButton(
                  label: s.reviewApplications,
                  onPressed: () =>
                      context.push('/opportunities/${o.id}/applications'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.read<OpportunityDetailBloc>().add(
                    ToggleSaveOpportunity(o.id),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(o.isSaved ? s.unsave : s.saveLabel),
                ),
              ],
              if (user == null)
                FhPrimaryButton(
                  label: s.signInToApply,
                  onPressed: () => context.go('/login'),
                ),
              if (user != null &&
                  user.isOpportunityProvider &&
                  !isProviderOwner)
                Text(
                  'You are signed in as a provider. Switch to an entrepreneur account to apply.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
            ],
          );
        },
      ),
    );
  }
}
