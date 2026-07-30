import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';
import '../../../../injection/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/entities/opportunity_application.dart';
import '../../domain/usecases/application_usecases.dart';
import '../../domain/usecases/opportunity_usecases.dart';

class ApplyOpportunityPage extends StatefulWidget {
  const ApplyOpportunityPage({required this.opportunityId, super.key});

  final String opportunityId;

  @override
  State<ApplyOpportunityPage> createState() => _ApplyOpportunityPageState();
}

class _ApplyOpportunityPageState extends State<ApplyOpportunityPage> {
  Opportunity? _opportunity;
  bool _loading = true;
  bool _submitting = false;
  bool _eligibilityConfirmed = false;

  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _fundingController = TextEditingController();
  final _useOfFundsController = TextEditingController();
  final _teamSizeController = TextEditingController(text: '1');
  final _yearsController = TextEditingController(text: '0');
  final _impactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _locationController.dispose();
    _fundingController.dispose();
    _useOfFundsController.dispose();
    _teamSizeController.dispose();
    _yearsController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final opportunity = await sl<GetOpportunityById>()(widget.opportunityId);
      if (!mounted) return;
      setState(() {
        _opportunity = opportunity;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final opportunity = _opportunity;
    if (opportunity == null) return;

    final phone = _phoneController.text.trim();
    final businessName = _businessNameController.text.trim();
    final businessDescription = _businessDescriptionController.text.trim();
    final location = _locationController.text.trim();
    final funding = _fundingController.text.trim();
    final useOfFunds = _useOfFundsController.text.trim();
    final impact = _impactController.text.trim();

    if (phone.isEmpty ||
        businessName.isEmpty ||
        businessDescription.isEmpty ||
        location.isEmpty ||
        funding.isEmpty ||
        useOfFunds.isEmpty ||
        impact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required application fields.'),
        ),
      );
      return;
    }
    if (!_eligibilityConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirm that you meet the eligibility criteria.'),
        ),
      );
      return;
    }

    final user = await sl<AuthRepository>().getCurrentUser();
    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in to apply.')));
      return;
    }
    if (user.isOpportunityProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Provider accounts review applications; entrepreneurs apply.',
          ),
        ),
      );
      return;
    }
    if (opportunity.createdBy == null || opportunity.createdBy!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This listing has no provider owner, so applications cannot be reviewed.',
          ),
        ),
      );
      return;
    }

    final existing = await sl<GetMyApplicationForOpportunity>()(
      opportunityId: opportunity.id,
      applicantId: user.id,
    );
    if (!mounted) return;
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You already applied (${existing.statusLabel}).'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final id = 'app-${DateTime.now().millisecondsSinceEpoch}';
      await sl<SubmitApplication>()(
        OpportunityApplication(
          id: id,
          opportunityId: opportunity.id,
          opportunityTitle: opportunity.title,
          providerId: opportunity.createdBy!,
          applicantId: user.id,
          applicantName: user.fullName,
          applicantEmail: user.email,
          applicantPhone: phone,
          businessName: businessName,
          businessDescription: businessDescription,
          location: location,
          fundingRequested: funding,
          howFundsWillBeUsed: useOfFunds,
          teamSize: int.tryParse(_teamSizeController.text.trim()) ?? 1,
          yearsInOperation: int.tryParse(_yearsController.text.trim()) ?? 0,
          impactStatement: impact,
          eligibilityConfirmed: true,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted. The provider will review it.'),
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not submit: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = _opportunity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Apply'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : opportunity == null
          ? const Center(child: Text('Opportunity not found'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  opportunity.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  opportunity.organization,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (opportunity.eligibilityCriteria.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Eligibility you must meet',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(opportunity.eligibilityCriteria),
                ],
                const SizedBox(height: 18),
                Text(
                  'Your details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                _field(
                  _phoneController,
                  'Phone number *',
                  keyboardType: TextInputType.phone,
                ),
                _field(_locationController, 'District / city *'),
                _field(_businessNameController, 'Business / venture name *'),
                _field(
                  _businessDescriptionController,
                  'What does your venture do? *',
                  maxLines: 3,
                ),
                _field(_fundingController, 'Funding amount requested *'),
                _field(
                  _useOfFundsController,
                  'How will funds be used? *',
                  maxLines: 3,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _teamSizeController,
                        'Team size *',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        _yearsController,
                        'Years operating *',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                _field(
                  _impactController,
                  'Expected impact / why you qualify *',
                  maxLines: 4,
                ),
                CheckboxListTile(
                  value: _eligibilityConfirmed,
                  onChanged: (v) =>
                      setState(() => _eligibilityConfirmed = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'I confirm I meet the eligibility criteria and conditions listed above.',
                  ),
                ),
                const SizedBox(height: 12),
                FhPrimaryButton(
                  label: _submitting ? 'Submitting...' : 'Submit application',
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
    );
  }
}
