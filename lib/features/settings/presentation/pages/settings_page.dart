import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../injection/injection.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
        title: Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.avatarBg,
                  child: Text('J'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jean-Luc Bizimana',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Agri-Tech Founder',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel(context, 'ACCOUNT & SECURITY'),
          _settingsCard(
            context,
            children: [
              _tile(
                context,
                icon: Icons.person_outline,
                label: 'Account',
                onTap: () => context.push('/edit-profile'),
              ),
              const Divider(height: 1),
              _tile(
                context,
                icon: Icons.notifications_none,
                label: 'Notification Settings',
                onTap: () => context.push('/notification-settings'),
              ),
              const Divider(height: 1),
              _tile(
                context,
                icon: Icons.lock_outline,
                label: 'Privacy',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),
          _sectionLabel(context, 'PREFERENCES'),
          _settingsCard(
            context,
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: AppColors.primary),
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),
          _sectionLabel(context, 'SUPPORT'),
          _settingsCard(
            context,
            children: [
              _tile(
                context,
                icon: Icons.help_outline,
                label: 'Help Center',
                onTap: () {},
              ),
              const Divider(height: 1),
              _tile(
                context,
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: Text(
                'Logout',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                await sl<AuthRepository>().logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                Text(
                  'FundaHub v2.4.0',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  "Made for Rwanda's Entrepreneurs",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _settingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
