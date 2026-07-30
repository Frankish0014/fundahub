import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../injection/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/opportunity_application.dart';
import '../../domain/usecases/application_usecases.dart';

class ApplicationReviewPage extends StatefulWidget {
  const ApplicationReviewPage({required this.applicationId, super.key});

  final String applicationId;

  @override
  State<ApplicationReviewPage> createState() => _ApplicationReviewPageState();
}

class _ApplicationReviewPageState extends State<ApplicationReviewPage> {
  OpportunityApplication? _application;
  bool _loading = true;
  bool _acting = false;
  bool _canDecide = false;
  bool _isAdminViewer = false;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final app = await sl<GetApplicationById>()(widget.applicationId);
      final user = await sl<AuthRepository>().getCurrentUser();
      if (!mounted) return;
      final isOwner =
          user != null && app != null && user.id == app.providerId;
      setState(() {
        _application = app;
        _noteController.text = app?.reviewerNote ?? '';
        _canDecide = isOwner && user.isOpportunityProvider;
        _isAdminViewer = user?.isPlatformAdmin == true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _decide(ApplicationStatus status) async {
    final app = _application;
    if (app == null) return;

    final user = await sl<AuthRepository>().getCurrentUser();
    if (!mounted) return;
    // Only the owning provider decides applications — never Platform Admin.
    if (user == null ||
        user.id != app.providerId ||
        !user.isOpportunityProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only the opportunity provider can grant or reject.'),
        ),
      );
      return;
    }

    final note = _noteController.text.trim();
    if (status == ApplicationStatus.rejected && note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a reviewer note explaining the rejection.'),
        ),
      );
      return;
    }

    setState(() => _acting = true);
    try {
      await sl<ReviewApplication>()(
        applicationId: app.id,
        status: status,
        reviewerId: user.id,
        reviewerNote: note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == ApplicationStatus.granted
                ? 'Application granted.'
                : 'Application rejected.',
          ),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update: $e')));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '—' : value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = _application;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(_isAdminViewer ? 'Application activity' : 'Review application'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : app == null
          ? const Center(child: Text('Application not found'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_isAdminViewer) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Read-only. Admins monitor registration activity; only the provider can grant or reject applications. Admins approve opportunity listings separately.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                Text(
                  app.opportunityTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: ${app.statusLabel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Applicant',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _row('Full name', app.applicantName),
                _row('Email', app.applicantEmail),
                _row('Phone', app.applicantPhone),
                _row('Location', app.location),
                _row('Business / venture', app.businessName),
                _row('Business description', app.businessDescription),
                _row('Funding requested', app.fundingRequested),
                _row('Use of funds', app.howFundsWillBeUsed),
                _row('Team size', '${app.teamSize}'),
                _row('Years in operation', '${app.yearsInOperation}'),
                _row('Impact / qualification', app.impactStatement),
                _row(
                  'Eligibility confirmed',
                  app.eligibilityConfirmed ? 'Yes' : 'No',
                ),
                if (_canDecide) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reviewer decision note',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    enabled: !app.isFinal,
                    decoration: const InputDecoration(
                      hintText:
                          'Reference eligibility/conditions when granting or rejecting',
                    ),
                  ),
                ],
                if (app.reviewerNote.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Provider note: ${app.reviewerNote}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_canDecide && !app.isFinal) ...[
                  const SizedBox(height: 20),
                  FhPrimaryButton(
                    label: _acting ? 'Saving...' : 'Grant application',
                    onPressed: _acting
                        ? null
                        : () => _decide(ApplicationStatus.granted),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _acting
                        ? null
                        : () => _decide(ApplicationStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: AppColors.danger),
                    ),
                    child: const Text('Reject application'),
                  ),
                ],
              ],
            ),
    );
  }
}
