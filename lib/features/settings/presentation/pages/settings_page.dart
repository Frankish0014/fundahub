import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/locale/app_locale_controller.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_appearance_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../features/auth/domain/entities/user_profile.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../injection/injection.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserProfile? _user;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _errorMessage;

  AuthRepository get _authRepository => sl<AuthRepository>();
  AppLocaleController get _localeController => sl<AppLocaleController>();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;

        if (user == null) {
          _errorMessage = 'No signed-in user was found.';
        } else {
          _errorMessage = null;
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Could not load your account information.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openEditProfile() async {
    await context.push('/edit-profile');

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _loadCurrentUser();
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _authRepository.logout().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Still leave the app even if Google web sign-out hangs.
    }

    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _changeLanguage() async {
    final user = _user;
    if (user == null || !mounted) return;

    final s = AppStrings.of(context);
    final currentCode = _localeController.languageCode;

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(s.language),
          children: AppConstants.supportedLanguages.entries.map((entry) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, entry.key),
              child: Row(
                children: [
                  Expanded(child: Text(entry.value)),
                  if (currentCode == entry.key)
                    Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            );
          }).toList(),
        );
      },
    );

    if (!mounted || selected == null || selected == currentCode) return;

    // Update UI + SharedPreferences immediately so language switches at once.
    await _localeController.setLanguage(selected);

    try {
      final updated = await _authRepository.updateProfile(
        fullName: user.fullName,
        role: user.role,
        bio: user.bio,
        photoUrl: user.photoUrl,
        language: selected,
      );
      if (!mounted) return;
      setState(() => _user = updated);
    } catch (_) {
      // Locale already applied locally; profile sync can retry later.
    }

    if (!mounted) return;
    final name =
        AppConstants.supportedLanguages[selected] ?? selected;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).languageSetTo(name))),
    );
  }

  Future<void> _changeTheme() async {
    final appearance = sl<AppAppearanceController>();
    final s = AppStrings.of(context);
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(s.theme),
          children: [
            for (final option in [
              (ThemeMode.system, s.themeSystem),
              (ThemeMode.light, s.themeLight),
              (ThemeMode.dark, s.themeDark),
            ])
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, option.$1),
                child: Row(
                  children: [
                    Expanded(child: Text(option.$2)),
                    if (appearance.themeMode == option.$1)
                      Icon(Icons.check, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        );
      },
    );

    if (!mounted || selected == null) return;
    await appearance.setThemeMode(selected);
  }

  Future<void> _changeTextSize() async {
    final appearance = sl<AppAppearanceController>();
    final s = AppStrings.of(context);
    final selected = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(s.textSize),
          children: [
            for (final option in [
              (0.9, s.textSmall),
              (1.0, s.textDefault),
              (1.2, s.textLarge),
            ])
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, option.$1),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.$2,
                        style: TextStyle(fontSize: 16 * option.$1),
                      ),
                    ),
                    if ((appearance.textScale - option.$1).abs() < 0.01)
                      Icon(Icons.check, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        );
      },
    );

    if (!mounted || selected == null) return;
    await appearance.setTextScale(selected);
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
        title: Text(
          s.settings,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildBody(context, s),
    );
  }

  Widget _buildBody(BuildContext context, AppStrings s) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Could not find your profile.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  _loadCurrentUser();
                },
                child: Text(s.retry),
              ),
            ],
          ),
        ),
      );
    }

    final user = _user!;

    return ListView(
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
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.avatarBg,
                backgroundImage: ProfileAvatar.imageProvider(user.photoUrl),
                child: ProfileAvatar.imageProvider(user.photoUrl) == null
                    ? Text(
                        user.initial,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.role,
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
        _sectionLabel(context, s.accountSecurity),
        _settingsCard(
          context,
          children: [
            _tile(
              context,
              icon: Icons.person_outline,
              label: s.account,
              onTap: _openEditProfile,
            ),
            const Divider(height: 1),
            _tile(
              context,
              icon: Icons.notifications_none,
              label: s.notificationSettings,
              onTap: () => context.push('/notification-settings'),
            ),
            const Divider(height: 1),
            _tile(
              context,
              icon: Icons.lock_outline,
              label: s.privacy,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 18),
        _sectionLabel(context, s.preferences),
        ListenableBuilder(
          listenable: Listenable.merge([
            sl<AppAppearanceController>(),
            _localeController,
          ]),
          builder: (context, _) {
            final strings = AppStrings.of(context);
            final appearance = sl<AppAppearanceController>();
            final langCode = _localeController.languageCode;
            return _settingsCard(
              context,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.language,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    strings.language,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    AppConstants.supportedLanguages[langCode] ?? 'English',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                  onTap: _changeLanguage,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.palette_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    strings.theme,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    appearance.themeLabelFor(
                      light: strings.themeLight,
                      dark: strings.themeDark,
                      system: strings.themeSystem,
                    ),
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                  onTap: _changeTheme,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.text_fields,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    strings.textSize,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    appearance.textSizeLabelFor(
                      small: strings.textSmall,
                      defaults: strings.textDefault,
                      large: strings.textLarge,
                    ),
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                  onTap: _changeTextSize,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.view_compact_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    strings.compactMode,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    strings.compactModeSubtitle,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  value: appearance.compactMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => appearance.setCompactMode(value),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _sectionLabel(context, s.support),
        _settingsCard(
          context,
          children: [
            _tile(
              context,
              icon: Icons.help_outline,
              label: s.helpCenter,
              onTap: () {},
            ),
            const Divider(height: 1),
            _tile(
              context,
              icon: Icons.description_outlined,
              label: s.termsOfService,
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
            leading: Icon(Icons.logout, color: AppColors.danger),
            title: Text(
              _isLoggingOut ? s.loggingOut : s.logout,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: _isLoggingOut ? null : _logout,
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
                s.madeForRwanda,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
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
      title: Text(
        label,
        style: TextStyle(color: AppColors.textPrimary),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
