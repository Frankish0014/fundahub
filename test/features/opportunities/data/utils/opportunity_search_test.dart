import 'package:flutter_test/flutter_test.dart';
import 'package:fundahub/features/opportunities/data/utils/opportunity_search.dart';
import 'package:fundahub/features/opportunities/domain/entities/opportunity.dart';

const _rdb = Opportunity(
  id: '1',
  title: 'RDB SME Growth Facility',
  organization: 'Rwanda Development Board',
  type: OpportunityType.grant,
  amountLabel: 'Up to RWF 50M',
  tags: ['SME Owner', 'Scale-up'],
  daysLeft: 18,
);

const _google = Opportunity(
  id: '2',
  title: 'Google for Startups Accelerator',
  organization: 'Google',
  type: OpportunityType.accelerator,
  amountLabel: 'Equity-free',
  tags: ['Tech'],
  daysLeft: 40,
);

void main() {
  test('matches title and organization substrings', () {
    expect(OpportunitySearch.matches(_rdb, 'rdb'), isTrue);
    expect(OpportunitySearch.matches(_rdb, 'rwanda'), isTrue);
    expect(OpportunitySearch.matches(_rdb, 'google'), isFalse);
  });

  test('does not match every listing just because it has a type', () {
    expect(OpportunitySearch.matches(_google, 'rdb'), isFalse);
    expect(OpportunitySearch.matches(_rdb, 'xyz-nope'), isFalse);
  });

  test('matches category labels and type synonyms to the right type only', () {
    expect(OpportunitySearch.matches(_rdb, 'Grants'), isTrue);
    expect(OpportunitySearch.matches(_google, 'Grants'), isFalse);
    expect(OpportunitySearch.matches(_google, 'accelerator'), isTrue);
  });

  test('filter combines query and type chips', () {
    final results = OpportunitySearch.filter(
      opportunities: const [_rdb, _google],
      query: '',
      types: {OpportunityType.grant},
    );
    expect(results, const [_rdb]);
  });
}
