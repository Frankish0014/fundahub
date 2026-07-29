import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/pending_moderation_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../core/widgets/fh_text_field.dart';
import '../../../../injection/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../notifications/domain/usecases/get_notifications.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required.')),
      );
      return;
    }

    final user = await sl<AuthRepository>().getCurrentUser();
    if (!mounted) return;
    if (user == null || !user.canPublishContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only provider accounts can post announcements.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final isAdmin = user.isPlatformAdmin;
      await sl<CreateAnnouncement>()(
        title: title,
        body: body,
        createdBy: user.id,
        organization: user.fullName,
        moderationStatus: isAdmin ? 'approved' : 'pending',
      );
      if (!mounted) return;
      unawaited(sl<PendingModerationController>().refresh());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAdmin
                ? 'Announcement posted to Notifications.'
                : 'Submitted for admin review. It will appear in Notifications after approval.',
          ),
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not post: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Post Announcement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FhTextField(
            controller: _titleController,
            hintText: 'Announcement title',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Write the announcement for entrepreneurs...',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: 24),
          FhPrimaryButton(
            label: _saving ? 'Posting...' : 'Post Announcement',
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
