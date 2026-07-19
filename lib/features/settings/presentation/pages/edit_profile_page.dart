import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../core/widgets/fh_text_field.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../injection/injection.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Kwame Mensah');
  final _bioController = TextEditingController(
    text:
        'Building fintech solutions for sub-Saharan Africa with a focus on inclusive access.',
  );
  String _role = 'Tech Entrepreneur';
  final Set<String> _selected = {'Fintech', 'Agriculture', 'Grants'};
  final Set<String> _suggested = {
    'Blockchain',
    'Education',
    'Sustainability',
    ...AppConstants.interestTags,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = sl<AuthRepository>();
    await repo.updateProfile(
      fullName: _nameController.text.trim(),
      role: _role,
    );
    await repo.updateInterests(_selected.toList());
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    context.pop();
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
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.avatarBg,
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Change Photo',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Full Name',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          FhTextField(
            hintText: 'Full Name',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Role',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _role,
            items: {
              ...AppConstants.entrepreneurRoles,
              'Tech Entrepreneur',
              'Agri-Tech Founder',
            }.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _role = v ?? _role),
            decoration: const InputDecoration(),
          ),
          const SizedBox(height: 16),
          Text(
            'Bio',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Tell your story...'),
          ),
          const SizedBox(height: 20),
          Container(
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
                      onPressed: () {},
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._selected.map(
                      (tag) => InputChip(
                        label: Text(tag),
                        selected: true,
                        onDeleted: () => setState(() => _selected.remove(tag)),
                        selectedColor: AppColors.primary,
                        labelStyle: const TextStyle(color: AppColors.onPrimary),
                        deleteIconColor: AppColors.onPrimary,
                        showCheckmark: false,
                      ),
                    ),
                    ..._suggested
                        .where((t) => !_selected.contains(t))
                        .take(4)
                        .map(
                          (tag) => ActionChip(
                            label: Text('+ $tag'),
                            backgroundColor: AppColors.interestChipBg,
                            labelStyle: const TextStyle(
                              color: AppColors.interestChipText,
                            ),
                            onPressed: () => setState(() => _selected.add(tag)),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FhPrimaryButton(label: 'Save Changes', onPressed: _save),
        ],
      ),
    );
  }
}
