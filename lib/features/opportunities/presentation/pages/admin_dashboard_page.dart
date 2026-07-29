import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/current_user_controller.dart';
import '../../../../core/session/pending_moderation_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../../../notifications/domain/repositories/notification_repository.dart';
import '../../../notifications/domain/usecases/get_notifications.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/usecases/opportunity_usecases.dart';

/// Platform Super Admin home — approve / reject provider submissions.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Opportunity> _pending = const [];
  List<AppNotification> _pendingAnnouncements = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await sl<GetPendingOpportunities>()();
      final announcements = await sl<GetPendingAnnouncements>()();
      if (!mounted) return;
      setState(() {
        _pending = items;
        _pendingAnnouncements = announcements;
        _loading = false;
      });
      await sl<PendingModerationController>().refresh();
      sl<PendingModerationController>().bump();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _reviewAnnouncement(
    AppNotification announcement,
    bool approve,
  ) async {
    final admin = sl<CurrentUserController>().user;
    if (admin == null || !admin.isPlatformAdmin) return;
    try {
      await sl<ReviewAnnouncement>()(
        id: announcement.id,
        moderationStatus: approve ? 'approved' : 'rejected',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Announcement approved — visible in Notifications.'
                : 'Announcement rejected.',
          ),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not review: $e')));
    }
  }

  Future<void> _review(Opportunity opportunity, ModerationStatus status) async {
    final admin = sl<CurrentUserController>().user;
    if (admin == null || !admin.isPlatformAdmin) return;

    var note = '';
    if (status == ModerationStatus.rejected) {
      final controller = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reject opportunity'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Reason for the provider (required)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      note = controller.text.trim();
      if (note.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a rejection reason.')),
        );
        return;
      }
    }

    try {
      await sl<ReviewOpportunity>()(
        opportunity: opportunity,
        status: status,
        reviewerId: admin.id,
        note: note,
      );

      final providerId = opportunity.createdBy;
      final approved = status == ModerationStatus.approved;
      if (providerId != null && providerId.isNotEmpty) {
        await sl<NotificationRepository>().notifyUser(
          targetUserId: providerId,
          title: approved ? 'Opportunity approved' : 'Opportunity not verified',
          body: approved
              ? '"${opportunity.title}" is now live for entrepreneurs on FundaHub.'
              : '"${opportunity.title}" was rejected. ${note.isEmpty ? '' : note}',
          organization: 'FundaHub Admin',
        );
      }

      if (approved) {
        await sl<NotificationRepository>().createAnnouncement(
          title: 'New verified opportunity: ${opportunity.title}',
          body:
              '${opportunity.organization} published a verified ${opportunity.typeLabel.toLowerCase()}. Open Search to apply.',
          createdBy: admin.id,
          organization: 'FundaHub',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == ModerationStatus.approved
                ? 'Approved — now visible to entrepreneurs.'
                : 'Rejected — provider notified.',
          ),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not review: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final admin = sl<CurrentUserController>().user;
    final firstName = admin?.firstName ?? 'Admin';
    final queueTotal = _pending.length + _pendingAnnouncements.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.brand,
                      AppColors.brand.withValues(alpha: 0.88),
                      const Color(0xFF0A5C45),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'SUPER ADMIN',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Spacer(),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                              child: Text(
                                firstName.isEmpty
                                    ? 'A'
                                    : firstName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Hey, $firstName',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verify provider listings before they reach young founders.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.88),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _HeroStat(
                                label: 'In queue',
                                value: '$queueTotal',
                                icon: Icons.pending_actions_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeroStat(
                                label: 'Listings',
                                value: '${_pending.length}',
                                icon: Icons.work_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeroStat(
                                label: 'Alerts',
                                value: '${_pendingAnnouncements.length}',
                                icon: Icons.campaign_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionHeader(
                    title: 'Needs your review',
                    count: _pending.length,
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_pending.isEmpty)
                    const _EmptyCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'You\'re all caught up',
                      body:
                          'New opportunities from NGOs and partners will land here for approval.',
                    )
                  else
                    ..._pending.map(
                      (opportunity) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReviewCard(
                          title: opportunity.title,
                          subtitle:
                              '${opportunity.organization} · ${opportunity.typeLabel}',
                          body: opportunity.description.isEmpty
                              ? opportunity.amountLabel
                              : opportunity.description,
                          accent: AppColors.accent,
                          onPreview: () =>
                              context.push('/opportunities/${opportunity.id}'),
                          onReject: () =>
                              _review(opportunity, ModerationStatus.rejected),
                          onApprove: () =>
                              _review(opportunity, ModerationStatus.approved),
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Announcement queue',
                    count: _pendingAnnouncements.length,
                  ),
                  const SizedBox(height: 12),
                  if (!_loading && _pendingAnnouncements.isEmpty)
                    const _EmptyCard(
                      icon: Icons.notifications_none_rounded,
                      title: 'No announcements waiting',
                      body:
                          'Provider alerts stay private until you approve them.',
                    )
                  else if (!_loading)
                    ..._pendingAnnouncements.map(
                      (announcement) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReviewCard(
                          title: announcement.title,
                          subtitle: 'Provider announcement',
                          body: announcement.body,
                          accent: scheme.primary,
                          onReject: () =>
                              _reviewAnnouncement(announcement, false),
                          onApprove: () =>
                              _reviewAnnouncement(announcement, true),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: count > 0
                ? AppColors.accent.withValues(alpha: 0.16)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelLarge?.copyWith(
              color: count > 0 ? AppColors.deadline : theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.accent,
    required this.onReject,
    required this.onApprove,
    this.onPreview,
  });

  final String title;
  final String subtitle;
  final String body;
  final Color accent;
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: AppColors.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.85)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (onPreview != null)
                  TextButton(
                    onPressed: onPreview,
                    child: const Text('Preview'),
                  ),
                const Spacer(),
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
