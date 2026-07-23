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
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  String _role = '';
  final Set<String> _selected = {};

  final Set<String> _suggested = {
    'Blockchain',
    'Education',
    'Sustainability',
    ...AppConstants.interestTags,
  };

  bool _isLoading = true;
  bool _isSaving = false;
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
        _nameController.text = user.firstName;
        _role = user.role;
        _selected
          ..clear()
          ..addAll(user.interests);

        _isLoading = false;
      });
    } catch (error) {
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
        const SnackBar(content: Text('Please select your role.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _authRepository.updateProfile(
        fullName: fullName,
        role: _role,
      );

      await _authRepository.updateInterests(_selected.toList());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );

      context.pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

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
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
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
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.avatarBg,
                    child: Text(
                      _getInitial(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
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
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
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
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _dropdownValue(),
          items: _availableRoles()
              .map(
                (role) => DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _role = value;
            });
          },
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 16),
        Text(
          'Bio',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _bioController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Tell your story...',
          ),
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
                      onDeleted: () {
                        setState(() {
                          _selected.remove(tag);
                        });
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: const TextStyle(
                        color: AppColors.onPrimary,
                      ),
                      deleteIconColor: AppColors.onPrimary,
                      showCheckmark: false,
                    ),
                  ),
                  ..._suggested
                      .where((tag) => !_selected.contains(tag))
                      .take(4)
                      .map(
                        (tag) => ActionChip(
                          label: Text('+ $tag'),
                          backgroundColor: AppColors.interestChipBg,
                          labelStyle: const TextStyle(
                            color: AppColors.interestChipText,
                          ),
                          onPressed: () {
                            setState(() {
                              _selected.add(tag);
                            });
                          },
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FhPrimaryButton(
  label: _isSaving ? 'Saving...' : 'Save Changes',
  onPressed: () async {
    if (!_isSaving) {
      await _save();
    }
  },
),
      ],
    );
  }

  Set<String> _availableRoles() {
    return {
      ...AppConstants.entrepreneurRoles,
      'Tech Entrepreneur',
      'Agri-Tech Founder',
      if (_role.isNotEmpty) _role,
    };
  }

  String? _dropdownValue() {
    if (_role.isEmpty) return null;
    return _role;
  }

  String _getInitial() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      return '?';
    }

    return name.substring(0, 1).toUpperCase();
  }
}