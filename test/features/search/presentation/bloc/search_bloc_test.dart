import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fundahub/features/auth/domain/entities/user_profile.dart';
import 'package:fundahub/features/auth/domain/usecases/auth_usecases.dart';
import 'package:fundahub/features/opportunities/domain/entities/opportunity.dart';
import 'package:fundahub/features/opportunities/domain/usecases/opportunity_usecases.dart';
import 'package:fundahub/features/search/presentation/bloc/search_bloc.dart';

class MockGetOpportunities extends Mock implements GetOpportunities {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

const _user = UserProfile(
  id: 'uid-1',
  fullName: 'Tifare Kaseke',
  email: 'tifare@example.com',
  role: 'Student Entrepreneur',
);

const _grant = Opportunity(
  id: 'op-1',
  title: 'RDB SME Growth Facility',
  organization: 'Rwanda Development Board',
  type: OpportunityType.grant,
  amountLabel: 'Up to RWF 50M',
  tags: ['SME Owner', 'Scale-up'],
  daysLeft: 18,
  isVerified: true,
  moderationStatus: ModerationStatus.approved,
);

const _accelerator = Opportunity(
  id: 'op-2',
  title: 'Google for Startups Accelerator',
  organization: 'Google',
  type: OpportunityType.accelerator,
  amountLabel: 'Equity-free',
  tags: ['Accelerator'],
  daysLeft: 45,
  isVerified: true,
  moderationStatus: ModerationStatus.approved,
);

void main() {
  late MockGetOpportunities getOpportunities;
  late MockGetCurrentUser getCurrentUser;

  setUp(() {
    getOpportunities = MockGetOpportunities();
    getCurrentUser = MockGetCurrentUser();
    when(() => getCurrentUser()).thenAnswer((_) async => _user);
  });

  SearchBloc buildBloc() => SearchBloc(
    getOpportunities: getOpportunities,
    getCurrentUser: getCurrentUser,
  );

  blocTest<SearchBloc, SearchState>(
    'emits [loading, success] with catalogue on SearchStarted',
    setUp: () {
      when(
        () => getOpportunities(
          query: any(named: 'query'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => const [_grant, _accelerator]);
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchStarted()),
    expect: () => [
      const SearchState(status: SearchStatus.loading),
      const SearchState(
        status: SearchStatus.success,
        catalogue: [_grant, _accelerator],
        results: [_grant, _accelerator],
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'SearchQueryChanged filters cached catalogue by title/org',
    setUp: () {
      when(
        () => getOpportunities(
          query: any(named: 'query'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => const [_grant, _accelerator]);
    },
    build: buildBloc,
    seed: () => const SearchState(
      status: SearchStatus.success,
      catalogue: [_grant, _accelerator],
      results: [_grant, _accelerator],
    ),
    act: (bloc) => bloc.add(const SearchQueryChanged('rdb')),
    expect: () => [
      const SearchState(
        status: SearchStatus.success,
        query: 'rdb',
        catalogue: [_grant, _accelerator],
        results: [_grant],
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'SearchFiltersChanged keeps only selected types',
    build: buildBloc,
    seed: () => const SearchState(
      status: SearchStatus.success,
      catalogue: [_grant, _accelerator],
      results: [_grant, _accelerator],
    ),
    act: (bloc) => bloc.add(
      const SearchFiltersChanged(selectedTypes: {OpportunityType.grant}),
    ),
    expect: () => [
      const SearchState(
        status: SearchStatus.success,
        catalogue: [_grant, _accelerator],
        results: [_grant],
        selectedTypes: {OpportunityType.grant},
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'emits failure when the repository throws',
    setUp: () {
      when(
        () => getOpportunities(
          query: any(named: 'query'),
          userId: any(named: 'userId'),
        ),
      ).thenThrow(Exception('network down'));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchStarted()),
    expect: () => [
      const SearchState(status: SearchStatus.loading),
      isA<SearchState>()
          .having((s) => s.status, 'status', SearchStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
  );
}
