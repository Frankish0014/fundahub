import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/pending_moderation_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/usecases/opportunity_usecases.dart';

/// Admin catalogue of every opportunity with moderation status.
class AdminCataloguePage extends StatefulWidget {
  const AdminCataloguePage({this.showPendingOnly = false, super.key});

  final bool showPendingOnly;

  @override
  State<AdminCataloguePage> createState() => _AdminCataloguePageState();
}

class _AdminCataloguePageState extends State<AdminCataloguePage> {
  List<Opportunity> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    sl<PendingModerationController>().addListener(_onModerationChanged);
    _load();
  }

  @override
  void dispose() {
    sl<PendingModerationController>().removeListener(_onModerationChanged);
    super.dispose();
  }

  void _onModerationChanged() {
    if (!mounted) return;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await sl<GetAllOpportunitiesForAdmin>()();
      final items = widget.showPendingOnly
          ? all
                .where((o) => o.moderationStatus == ModerationStatus.pending)
                .toList()
          : all;
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Color _statusColor(ModerationStatus status) {
    switch (status) {
      case ModerationStatus.approved:
        return AppColors.verified;
      case ModerationStatus.rejected:
        return AppColors.danger;
      case ModerationStatus.pending:
        return AppColors.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                widget.showPendingOnly ? 'Pending queue' : 'All opportunities',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                widget.showPendingOnly
                    ? 'Everything still waiting for Super Admin verification.'
                    : 'Full catalogue across every provider — only Approved items reach entrepreneurs.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: _loading
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : _items.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No opportunities yet.')),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final o = _items[index];
                          return Material(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () =>
                                  context.push('/opportunities/${o.id}'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            o.title,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              o.moderationStatus,
                                            ).withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            o.moderationLabel,
                                            style: TextStyle(
                                              color: _statusColor(
                                                o.moderationStatus,
                                              ),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      o.organization,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
