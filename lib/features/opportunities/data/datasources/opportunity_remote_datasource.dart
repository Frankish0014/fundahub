import '../../domain/entities/opportunity.dart';

abstract class OpportunityRemoteDataSource {
  Future<List<Opportunity>> fetchAll();
}

/// Local seed data matching the Figma screenshot content.
class OpportunityMockDataSource implements OpportunityRemoteDataSource {
  final List<Opportunity> _items = [
    const Opportunity(
      id: '1',
      title: 'Tony Elumelu Foundation Entrepreneurship Programme',
      organization: 'TEF',
      type: OpportunityType.grant,
      amountLabel: '\$5,000',
      tags: ['Seed Funding', 'Mentorship'],
      daysLeft: 27,
      isSaved: true,
    ),
    const Opportunity(
      id: '2',
      title: 'Google for Startups Accelerator: Africa',
      organization: 'Google',
      type: OpportunityType.accelerator,
      amountLabel: 'Equity-free support',
      tags: ['Tech', 'Scale-up'],
      daysLeft: 45,
      isSaved: true,
    ),
    const Opportunity(
      id: '3',
      title: 'Anzisha Prize for Young Entrepreneurs',
      organization: 'African Leadership Academy',
      type: OpportunityType.competition,
      amountLabel: '\$25,000',
      tags: ['Under 25', 'Africa'],
      daysLeft: 60,
    ),
    const Opportunity(
      id: '4',
      title: 'Mastercard Foundation Scholars Program',
      organization: 'Mastercard Foundation',
      type: OpportunityType.scholarship,
      amountLabel: 'Full funding',
      tags: ['Education', 'Youth'],
      daysLeft: 34,
    ),
  ];

  @override
  Future<List<Opportunity>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_items);
  }

  List<Opportunity> get mutableItems => _items;
}
