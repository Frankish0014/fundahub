import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../../domain/usecases/opportunity_usecases.dart';
import '../bloc/opportunity_detail_bloc.dart';
import '../bloc/opportunity_detail_event.dart';
import '../bloc/opportunity_detail_state.dart';

class OpportunityDetailPage extends StatelessWidget {
  const OpportunityDetailPage({required this.opportunityId, super.key});

  final String opportunityId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OpportunityDetailBloc(
        getOpportunityById: sl<GetOpportunityById>(),
        toggleSavedOpportunity: sl<ToggleSavedOpportunity>(),
      )..add(LoadOpportunityDetail(opportunityId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Opportunity'),
          centerTitle: true,
        ),
        body: BlocBuilder<OpportunityDetailBloc, OpportunityDetailState>(
          builder: (context, state) {
            if (state.status == OpportunityDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == OpportunityDetailStatus.error) {
              return Center(child: Text(state.errorMessage ?? 'Error'));
            }
            final o = state.opportunity;
            if (o == null) {
              return const Center(child: Text('Not found'));
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(o.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(o.organization),
                const SizedBox(height: 16),
                Text(o.amountLabel),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: o.tags.map((t) => Chip(label: Text(t))).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context
                      .read<OpportunityDetailBloc>()
                      .add(ToggleSaveOpportunity(o.id)),
                  child: Text(o.isSaved ? 'Unsave' : 'Save'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}