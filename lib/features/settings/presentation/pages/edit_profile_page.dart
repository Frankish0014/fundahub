import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/locale/app_locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../core/widgets/fh_text_field.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../injection/injection.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  String _role = '';
  String _email = '';
  String? _photoUrl;
  String _language = 'en';
  final Set<String> _selected = {};
  bool _isAdmin = false;
  bool _isProvider = false;

  final Set<String> _suggested = {
    'Blockchain',
    'Education',
    'Sustainability',
    ...AppConstants.interestTags,
  };

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;

  AuthRepository get _authRepository => sl<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _errorMessage = 'No signed-in user was found.';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _nameController.text = user.fullName;
        _bioController.text = user.bio;
        _role = user.role;
        _email = user.email;
        _photoUrl = user.photoUrl;
        _language = user.language.isEmpty ? 'en' : user.language;
        _isAdmin = user.isPlatformAdmin;
        _isProvider = user.isOpportunityProvider;
        _selected
          ..clear()
          ..addAll(user.interests);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load your profile. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: kIsWeb ? 512 : 1024,
      imageQuality: kIsWeb ? 75 : 85,
    );
    if (file == null) return;
    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = await file.readAsBytes();
      final updated = await _authRepository
          .uploadProfilePhoto(
            bytes: bytes,
            fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          )
          .timeout(const Duration(seconds: 30));
      if (!mounted) return;
      setState(() => _photoUrl = updated.photoUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not upload photo: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    final fullName = _nameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }
    if (_role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account role could not be loaded.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _authRepository.updateProfile(
        fullName: fullName,
        role: _role, // Locked to registration role — never changed here.
        bio: _bioController.text.trim(),
        photoUrl: _photoUrl,
        language: _language,
      );
      if (!_isAdmin) {
        await _authRepository.updateInterests(_selected.toList());
      }
      await sl<AppLocaleController>().setLanguage(_language);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update your profile. Please try again.'),
        ),
      );
    }
  }

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
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings_outlined, color: AppColors.primary),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadCurrentUser();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  ProfileAvatar(
                    photoUrl: _photoUrl,
                    initial: _getInitial(),
                    radius: 48,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isUploadingPhoto ? null : _pickPhoto,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: _isUploadingPhoto
                              ? const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: AppColors.onPrimary,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _isUploadingPhoto ? null : _pickPhoto,
                child: Text(
                  'Change Photo',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel(context, 'Full Name'),
        const SizedBox(height: 6),
        FhTextField(
          hintText: 'Full Name',
          controller: _nameController,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _fieldLabel(context, 'Email'),
        const SizedBox(height: 6),
        _LockedField(
          icon: Icons.mail_outline_rounded,
          value: _email.isEmpty ? '—' : _email,
          hint: 'Account email cannot be changed here',
        ),
        const SizedBox(height: 16),
        _fieldLabel(context, 'Account role'),
        const SizedBox(height: 6),
        _LockedField(
          icon: Icons.badge_outlined,
          value: _role.isEmpty ? '—' : _role,
          hint: 'Set at registration and cannot be changed',
        ),
        const SizedBox(height: 16),
        _fieldLabel(context, 'Bio'),
        const SizedBox(height: 6),
        TextField(
          controller: _bioController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: _isAdmin
                ? 'Describe your moderation / ops focus...'
                : 'Tell your story...',
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel(context, 'Language'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.supportedLanguages.entries.map((entry) {
            final selected = _language == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _language = entry.key),
              selectedColor: AppColors.mintSoft,
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        if (_isAdmin) ...[
          _AdminToolsCard(
            onReview: () => context.go('/home'),
            onCatalogue: () => context.go('/home/search'),
            onStatus: () => context.go('/home/saved'),
            onNotifications: () => context.go('/home/alerts'),
          ),
        ] else ...[
          _InterestsEditor(
            selected: _selected,
            suggested: _suggested,
            showProviderHint: _isProvider,
            onAdd: (tag) => setState(() => _selected.add(tag)),
            onRemove: (tag) => setState(() => _selected.remove(tag)),
            onQuickAdd: () {
              final remaining = _suggested
                  .where((tag) => !_selected.contains(tag))
                  .toList();
              if (remaining.isEmpty) return;
              setState(() => _selected.add(remaining.first));
            },
          ),
        ],
        const SizedBox(height: 24),
        FhPrimaryButton(
          label: _isSaving ? 'Saving...' : 'Save Changes',
          onPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
    );
  }

  String _getInitial() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({
    required this.icon,
    required this.value,
    required this.hint,
  });

  final IconData icon;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mintSoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _AdminToolsCard extends StatelessWidget {
  const _AdminToolsCard({
    required this.onReview,
    required this.onCatalogue,
    required this.onStatus,
    required this.onNotifications,
  });

  final VoidCallback onReview;
  final VoidCallback onCatalogue;
  final VoidCallback onStatus;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Super Admin tools',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Verify provider opportunities and announcements before they reach entrepreneurs.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          _AdminActionTile(
            icon: Icons.verified_user_outlined,
            title: 'Review queue',
            subtitle: 'Approve or reject pending listings',
            onTap: onReview,
          ),
          _AdminActionTile(
            icon: Icons.work_outline_rounded,
            title: 'Catalogue',
            subtitle: 'Browse every opportunity and status',
            onTap: onCatalogue,
          ),
          _AdminActionTile(
            icon: Icons.fact_check_outlined,
            title: 'Status board',
            subtitle: 'Track pending, approved, and rejected',
            onTap: onStatus,
          ),
          _AdminActionTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'See approval requests and system alerts',
            onTap: onNotifications,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
        if (!isLast) Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}

class _InterestsEditor extends StatelessWidget {
  const _InterestsEditor({
    required this.selected,
    required this.suggested,
    required this.onAdd,
    required this.onRemove,
    required this.onQuickAdd,
    this.showProviderHint = false,
  });

  final Set<String> selected;
  final Set<String> suggested;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onQuickAdd;
  final bool showProviderHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'My Interests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onQuickAdd,
                child: Text(
                  '+ Add Interest',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (showProviderHint) ...[
            Text(
              'Help entrepreneurs discover programmes that match these themes.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...selected.map(
                (tag) => InputChip(
                  label: Text(tag),
                  selected: true,
                  onDeleted: () => onRemove(tag),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: AppColors.onPrimary),
                  deleteIconColor: AppColors.onPrimary,
                  showCheckmark: false,
                ),
              ),
              ...suggested
                  .where((tag) => !selected.contains(tag))
                  .take(4)
                  .map(
                    (tag) => ActionChip(
                      label: Text('+ $tag'),
                      backgroundColor: AppColors.interestChipBg,
                      labelStyle: TextStyle(
                        color: AppColors.interestChipText,
                      ),
                      onPressed: () => onAdd(tag),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
