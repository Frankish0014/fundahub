import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/opportunity_card.dart';
import '../../../../injection/injection.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/usecases/opportunity_usecases.dart';

class ProviderHubPage extends StatefulWidget {
  const ProviderHubPage({super.key});

  @override
  State<ProviderHubPage> createState() => _ProviderHubPageState();
}

class _ProviderHubPageState extends State<ProviderHubPage> {
  UserProfile? _user;
  List<Opportunity> _myListings = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await sl<AuthRepository>().getCurrentUser();
      if (!mounted) return;
      if (user == null || !user.isOpportunityProvider) {
        setState(() {
          _user = user;
          _myListings = const [];
          _loading = false;
        });
        return;
      }

      final listings = await sl<GetMyOpportunities>()(userId: user.id);
      if (!mounted) return;
      setState(() {
        _user = user;
        _myListings = listings;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openCreate() async {
    final created = await context.push<bool>('/opportunities/create');
    if (created == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final allowed = user?.isOpportunityProvider ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Provider Hub'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: !allowed
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'This area is for NGOs, government partners, and platform admins. Create an account with a provider role to publish opportunities.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Welcome, ${user?.fullName ?? 'Partner'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.role ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _HubCard(
                    icon: Icons.add_box_outlined,
                    title: 'Create Opportunity',
                    subtitle:
                        'Publish a grant, accelerator, scholarship, or competition',
                    onTap: _openCreate,
                  ),
                  const SizedBox(height: 12),
                  _HubCard(
                    icon: Icons.campaign_outlined,
                    title: 'Post Announcement',
                    subtitle:
                        'Send an alert that appears in the Alerts tab for all users',
                    onTap: () => context.push('/announcements/create'),
                  ),
                  const SizedBox(height: 12),
                  _HubCard(
                    icon: Icons.assignment_outlined,
                    title: 'Applications inbox',
                    subtitle:
                        'Review, grant, or reject entrepreneur applications',
                    onTap: () => context.push('/provider/applications'),
                  ),
                  const SizedBox(height: 12),
                  _HubCard(
                    icon: Icons.search,
                    title: 'Browse Opportunities',
                    subtitle: 'See how entrepreneurs discover your listings',
                    onTap: () => context.go('/home/search'),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Text(
                        'My listings',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      if (_loading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!_loading && _myListings.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'No published opportunities yet. Create your first listing above.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  else
                    ..._myListings.map(
                      (opportunity) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OpportunityCard(
                          opportunity: opportunity,
                          onTap: () =>
                              context.push('/opportunities/${opportunity.id}'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
