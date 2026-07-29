import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/pending_moderation_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../injection/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/utils/opportunity_search.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/usecases/opportunity_usecases.dart';

class CreateOpportunityPage extends StatefulWidget {
  const CreateOpportunityPage({super.key});

  @override
  State<CreateOpportunityPage> createState() => _CreateOpportunityPageState();
}

class _CreateOpportunityPageState extends State<CreateOpportunityPage> {
  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  final _amountController = TextEditingController();
  final _tagsController = TextEditingController();
  final _daysController = TextEditingController(text: '30');
  final _descriptionController = TextEditingController();
  final _eligibilityController = TextEditingController();
  final _documentsController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _beneficiariesController = TextEditingController();

  OpportunityType _type = OpportunityType.grant;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    _amountController.dispose();
    _tagsController.dispose();
    _daysController.dispose();
    _descriptionController.dispose();
    _eligibilityController.dispose();
    _documentsController.dispose();
    _locationController.dispose();
    _contactEmailController.dispose();
    _instructionsController.dispose();
    _beneficiariesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final org = _orgController.text.trim();
    final amount = _amountController.text.trim();
    final description = _descriptionController.text.trim();
    final eligibility = _eligibilityController.text.trim();

    if (title.isEmpty ||
        org.isEmpty ||
        amount.isEmpty ||
        description.isEmpty ||
        eligibility.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill title, organisation, amount, description, and eligibility.',
          ),
        ),
      );
      return;
    }

    final user = await sl<AuthRepository>().getCurrentUser();
    if (!mounted) return;
    if (user == null || !user.isOpportunityProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only provider accounts can create opportunities.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final documents = _documentsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final mergedTags = <String>{
        ...OpportunitySearch.defaultTagsForType(_type),
        ...tags,
        user.role,
      }.toList();
      final days = int.tryParse(_daysController.text.trim()) ?? 30;
      final id = 'opp-${DateTime.now().millisecondsSinceEpoch}';

      await sl<CreateOpportunity>()(
        Opportunity(
          id: id,
          title: title,
          organization: org,
          type: _type,
          amountLabel: amount,
          tags: mergedTags,
          daysLeft: days,
          isVerified: false,
          moderationStatus: ModerationStatus.pending,
          createdBy: user.id,
          description: description,
          eligibilityCriteria: eligibility,
          requiredDocuments: documents.isEmpty
              ? const [
                  'National ID / passport',
                  'Business registration (if applicable)',
                  'Pitch / proposal summary',
                ]
              : documents,
          location: _locationController.text.trim().isEmpty
              ? 'Rwanda'
              : _locationController.text.trim(),
          contactEmail: _contactEmailController.text.trim().isEmpty
              ? user.email
              : _contactEmailController.text.trim(),
          applicationInstructions: _instructionsController.text.trim().isEmpty
              ? 'Submit a complete FundaHub application for provider review.'
              : _instructionsController.text.trim(),
          targetBeneficiaries: _beneficiariesController.text.trim(),
        ),
      );

      if (!mounted) return;
      // Keep Super Admin Status/Alerts dots in sync when a new review lands.
      unawaited(sl<PendingModerationController>().refresh());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Submitted for admin review. Entrepreneurs will see it only after approval.',
          ),
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not publish: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Create Opportunity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Basic details'),
          _field(_titleController, 'Opportunity title *'),
          _field(_orgController, 'Organisation / department *'),
          DropdownButtonFormField<OpportunityType>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Type *',
              border: OutlineInputBorder(),
            ),
            items: OpportunityType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.name.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _type = v);
            },
          ),
          const SizedBox(height: 12),
          _field(_amountController, 'Funding amount (e.g. Up to RWF 10M) *'),
          _field(
            _daysController,
            'Days until deadline *',
            keyboardType: TextInputType.number,
          ),
          _field(
            _locationController,
            'Coverage location (e.g. Kigali, Rwanda)',
          ),
          _field(_contactEmailController, 'Contact email for applicants'),
          _section('Programme content'),
          _field(
            _descriptionController,
            'Full description of the opportunity *',
            maxLines: 4,
          ),
          _field(
            _beneficiariesController,
            'Target beneficiaries (who should apply)',
            maxLines: 2,
          ),
          _field(
            _eligibilityController,
            'Eligibility criteria & conditions *',
            maxLines: 4,
          ),
          _field(
            _documentsController,
            'Required documents (comma separated)',
            maxLines: 2,
          ),
          _field(
            _instructionsController,
            'Application instructions for applicants',
            maxLines: 3,
          ),
          _field(_tagsController, 'Extra tags (comma separated)'),
          const SizedBox(height: 8),
          Text(
            'Applicants will fill a structured application that you can grant or reject against these criteria.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          FhPrimaryButton(
            label: _saving ? 'Publishing...' : 'Publish Opportunity',
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
