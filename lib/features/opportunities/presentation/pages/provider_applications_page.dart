import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/opportunity_application.dart';
import '../../domain/usecases/application_usecases.dart';

class ProviderApplicationsPage extends StatefulWidget {
  const ProviderApplicationsPage({
    this.opportunityId,
    this.embedded = false,
    super.key,
  });

  /// When set, only applications for this opportunity are shown.
  final String? opportunityId;

  /// When true, renders as a shell tab (no back button).
  final bool embedded;

  @override
  State<ProviderApplicationsPage> createState() =>
      _ProviderApplicationsPageState();
}

class _ProviderApplicationsPageState extends State<ProviderApplicationsPage> {
  List<OpportunityApplication> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await sl<AuthRepository>().getCurrentUser();
      if (user == null || !user.isOpportunityProvider) {
        setState(() {
          _items = const [];
          _loading = false;
          _error = 'Only providers can review applications.';
        });
        return;
      }

      final List<OpportunityApplication> items;
      if (widget.opportunityId != null) {
        items = await sl<GetOpportunityApplications>()(
          opportunityId: widget.opportunityId!,
        );
      } else {
        items = await sl<GetProviderApplications>()(providerId: user.id);
      }

      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.granted:
        return AppColors.verified;
      case ApplicationStatus.rejected:
        return AppColors.danger;
      case ApplicationStatus.underReview:
        return AppColors.deadline;
      case ApplicationStatus.withdrawn:
        return AppColors.textMuted;
      case ApplicationStatus.pending:
        return AppColors.primary;
    }
  }

  Widget _listBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: _items.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No applications yet.')),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final app = _items[index];
                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await context.push('/applications/${app.id}');
                      await _load();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  app.applicantName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    app.status,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  app.statusLabel,
                                  style: TextStyle(
                                    color: _statusColor(app.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app.opportunityTitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${app.businessName} · ${app.fundingRequested}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.embedded) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  'Applications',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Review, grant, or reject entrepreneur applications',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: _listBody(context)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          widget.opportunityId == null
              ? 'Applications inbox'
              : 'Listing applications',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _listBody(context),
    );
  }
}
