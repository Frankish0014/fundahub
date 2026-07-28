import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/current_user_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../injection/injection.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/entities/opportunity_application.dart';
import '../../domain/usecases/application_usecases.dart';
import '../../domain/usecases/opportunity_usecases.dart';

/// Home tab for NGOs / government partners / platform admins.
class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  List<Opportunity> _listings = const [];
  List<OpportunityApplication> _applications = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = sl<CurrentUserController>().user;
    if (user == null || !user.isOpportunityProvider) {
      setState(() {
        _listings = const [];
        _applications = const [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final listings = await sl<GetMyOpportunities>()(userId: user.id);
      final apps = await sl<GetProviderApplications>()(providerId: user.id);
      if (!mounted) return;
      setState(() {
        _listings = listings;
        _applications = apps;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  int get _pendingCount => _applications
      .where(
        (a) =>
            a.status == ApplicationStatus.pending ||
            a.status == ApplicationStatus.underReview,
      )
      .length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: sl<CurrentUserController>(),
      builder: (context, _) {
        final user = sl<CurrentUserController>().user;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: _load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _ProviderHeader(user: user)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Listings',
                                value: '${_listings.length}',
                                icon: Icons.work_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Pending',
                                value: '$_pendingCount',
                                icon: Icons.inbox_outlined,
                                highlight: _pendingCount > 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Total apps',
                                value: '${_applications.length}',
                                icon: Icons.people_outline_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Quick actions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActionTile(
                          icon: Icons.add_box_outlined,
                          title: 'Create opportunity',
                          subtitle: 'Publish a grant, scholarship, or programme',
                          onTap: () async {
                            final created = await context.push<bool>(
                              '/opportunities/create',
                            );
                            if (created == true) await _load();
                          },
                        ),
                        const SizedBox(height: 10),
                        _ActionTile(
                          icon: Icons.campaign_outlined,
                          title: 'Post announcement',
                          subtitle: 'Notify entrepreneurs in Alerts',
                          onTap: () => context.push('/announcements/create'),
                        ),
                        const SizedBox(height: 10),
                        _ActionTile(
                          icon: Icons.assignment_outlined,
                          title: 'Review applications',
                          subtitle: _pendingCount > 0
                              ? '$_pendingCount waiting for your decision'
                              : 'Open your applications inbox',
                          onTap: () => context.go('/home/saved'),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Text(
                              'Recent applications',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.go('/home/saved'),
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_applications.isEmpty)
                          _EmptyHint(
                            text:
                                'No applications yet. Publish an opportunity to start receiving them.',
                          )
                        else
                          ..._applications.take(4).map((app) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ApplicationPreview(
                                application: app,
                                onTap: () async {
                                  await context.push('/applications/${app.id}');
                                  await _load();
                                },
                              ),
                            );
                          }),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Your listings',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.go('/home/search'),
                              child: const Text('Manage'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_listings.isEmpty)
                          _EmptyHint(
                            text:
                                'You have not published any opportunities yet.',
                          )
                        else
                          ..._listings.take(3).map((opportunity) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ListingPreview(
                                opportunity: opportunity,
                                onTap: () => context.push(
                                  '/opportunities/${opportunity.id}',
                                ),
                              ),
                            );
                          }),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProviderHeader extends StatelessWidget {
  const _ProviderHeader({required this.user});

  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user?.fullName.trim();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 18,
        20,
        22,
      ),
      decoration: BoxDecoration(color: AppColors.primary),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
            backgroundImage: ProfileAvatar.imageProvider(user?.photoUrl),
            child: ProfileAvatar.imageProvider(user?.photoUrl) == null
                ? Text(
                    user?.initial ?? 'P',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provider workspace',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (name == null || name.isEmpty) ? 'Partner' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user?.role != null)
                  Text(
                    user!.role,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/home/alerts'),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? scheme.primary.withValues(alpha: 0.14)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationPreview extends StatelessWidget {
  const _ApplicationPreview({required this.application, required this.onTap});

  final OpportunityApplication application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      application.opportunityTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  application.statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingPreview extends StatelessWidget {
  const _ListingPreview({required this.opportunity, required this.onTap});

  final Opportunity opportunity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      opportunity.amountLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
