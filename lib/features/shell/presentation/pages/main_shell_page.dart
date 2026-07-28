import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/session/current_user_controller.dart';
import '../../../../core/session/pending_moderation_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([
        sl<CurrentUserController>(),
        sl<PendingModerationController>(),
      ]),
      builder: (context, _) {
        final isProvider = sl<CurrentUserController>().isOpportunityProvider;
        final isAdmin = sl<CurrentUserController>().isPlatformAdmin;
        final pending = sl<PendingModerationController>();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: navigationShell,
          bottomNavigationBar: Material(
            elevation: 0,
            color: scheme.surface,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.7),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: isAdmin
                            ? s.navReview
                            : isProvider
                            ? s.navDashboard
                            : s.navHome,
                        selected: navigationShell.currentIndex == 0,
                        onTap: () => _onTap(0),
                      ),
                      _NavItem(
                        icon: isAdmin || isProvider
                            ? Icons.work_outline_rounded
                            : Icons.search_rounded,
                        selectedIcon: isAdmin || isProvider
                            ? Icons.work_rounded
                            : Icons.search_rounded,
                        label: isAdmin
                            ? s.navCatalogue
                            : isProvider
                            ? s.navListings
                            : s.navSearch,
                        selected: navigationShell.currentIndex == 1,
                        onTap: () => _onTap(1),
                      ),
                      _NavItem(
                        icon: isAdmin
                            ? Icons.fact_check_outlined
                            : isProvider
                            ? Icons.inbox_outlined
                            : Icons.bookmark_border_rounded,
                        selectedIcon: isAdmin
                            ? Icons.fact_check_rounded
                            : isProvider
                            ? Icons.inbox_rounded
                            : Icons.bookmark_rounded,
                        label: isAdmin
                            ? s.navStatus
                            : isProvider
                            ? s.navInbox
                            : s.navSaved,
                        selected: navigationShell.currentIndex == 2,
                        showBadge: isAdmin && pending.showStatusBadge,
                        onTap: () => _onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.notifications_none_rounded,
                        selectedIcon: Icons.notifications_rounded,
                        label: s.navAlerts,
                        selected: navigationShell.currentIndex == 3,
                        showBadge: isAdmin && pending.showAlertsBadge,
                        onTap: () => _onTap(3),
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        selectedIcon: Icons.person_rounded,
                        label: s.navProfile,
                        selected: navigationShell.currentIndex == 4,
                        onTap: () => _onTap(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedIcon,
    this.showBadge = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final bool showBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : AppColors.navInactive;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected ? (selectedIcon ?? icon) : icon,
                    color: color,
                    size: 24,
                  ),
                  if (showBadge)
                    Positioned(
                      right: -3,
                      top: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
