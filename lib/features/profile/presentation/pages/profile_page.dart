import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../injection/injection.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileBloc(getCurrentUser: sl(), currentUser: sl())
            ..add(const ProfileStarted()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final pageBg = theme.scaffoldBackgroundColor;
    final cardBg = isDark ? AppColors.surfaceElevated : AppColors.surface;
    final onCard = scheme.onSurface;
    final onCardMuted = scheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: pageBg,
      body: ColoredBox(
        color: pageBg,
        child: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final user = state.user;
              final s = AppStrings.of(context);
              if (state.status == ProfileStatus.loading ||
                  state.status == ProfileStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == ProfileStatus.failure || user == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 48,
                          color: onCardMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage ??
                              'Please sign in to view your profile.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: onCard,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.go('/login'),
                          child: Text(s.logIn),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  Row(
                    children: [
                      Text(
                        s.profile,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onCard,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        style: IconButton.styleFrom(
                          foregroundColor: onCardMuted,
                          backgroundColor: cardBg,
                          side: BorderSide(color: scheme.outline),
                        ),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Material(
                    color: cardBg,
                    elevation: isDark ? 0 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: scheme.outline),
                    ),
                    child: InkWell(
                      onTap: () => context.push('/edit-profile').then((_) {
                        if (context.mounted) {
                          context.read<ProfileBloc>().add(
                            const ProfileStarted(),
                          );
                        }
                      }),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: scheme.primary.withValues(alpha: 0.55),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.avatarBg,
                                backgroundImage: ProfileAvatar.imageProvider(
                                  user.photoUrl,
                                ),
                                child:
                                    ProfileAvatar.imageProvider(
                                          user.photoUrl,
                                        ) ==
                                        null
                                    ? Text(
                                        user.initial,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: scheme.primary,
                                            ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: onCard,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.role,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: onCardMuted,
                                    ),
                                  ),
                                  if (user.bio.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      user.bio,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (user.isPlatformAdmin) ...[
                    _ProfileMenuTile(
                      icon: Icons.verified_user_outlined,
                      label: 'Admin review',
                      onTap: () => context.go('/home'),
                    ),
                    const SizedBox(height: 10),
                    _ProfileMenuTile(
                      icon: Icons.work_outline_rounded,
                      label: 'Catalogue',
                      onTap: () => context.go('/home/search'),
                    ),
                    const SizedBox(height: 10),
                    _ProfileMenuTile(
                      icon: Icons.fact_check_outlined,
                      label: 'Status board',
                      onTap: () => context.go('/home/saved'),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: scheme.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Super Admin',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: onCard,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your role was set at registration and cannot be changed. '
                            'Use Review and Notifications to verify provider content.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: scheme.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.myInterests,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: onCard,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (user.interests.isEmpty)
                            Text(
                              '—',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: user.interests
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? scheme.primary.withValues(
                                                alpha: 0.16,
                                              )
                                            : AppColors.interestChipBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: scheme.primary.withValues(
                                            alpha: isDark ? 0.35 : 0.2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: isDark
                                                  ? const Color(0xFFC5F2D9)
                                                  : AppColors.interestChipText,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (!user.isOpportunityProvider && !user.isPlatformAdmin) ...[
                    _ProfileMenuTile(
                      icon: Icons.menu_book_outlined,
                      label: s.trainingResources,
                      onTap: () => context.push('/resources'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  _ProfileMenuTile(
                    icon: Icons.groups_outlined,
                    label: s.community,
                    onTap: () => context.push('/community'),
                  ),
                  if (!user.isOpportunityProvider && !user.isPlatformAdmin) ...[
                    const SizedBox(height: 10),
                    _ProfileMenuTile(
                      icon: Icons.account_balance_outlined,
                      label: s.governmentProgrammes,
                      onTap: () => context.push('/government'),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceElevated : AppColors.surface;

    return Material(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.primary.withValues(alpha: 0.14)
                      : AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
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
