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
  title: 'Google for Startups Accelerator',
  organization: 'Google',
  type: OpportunityType.accelerator,
  amountLabel: 'Equity-free',
  tags: ['Accelerator'],
  daysLeft: 45,
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
    'emits [loading, success] with results on SearchStarted',
    setUp: () {
      when(
        () => getOpportunities(
          query: any(named: 'query'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => const [_grant]);
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchStarted()),
    expect: () => [
      const SearchState(status: SearchStatus.loading),
      const SearchState(status: SearchStatus.success, results: [_grant]),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'SearchQueryChanged filters by the typed query and re-emits results',
    setUp: () {
      when(
        () => getOpportunities(query: 'accelerator', userId: _user.id),
      ).thenAnswer((_) async => const [_grant]);
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchQueryChanged('accelerator')),
    expect: () => [
      const SearchState(status: SearchStatus.loading, query: 'accelerator'),
      const SearchState(
        status: SearchStatus.success,
        query: 'accelerator',
        results: [_grant],
      ),
    ],
    verify: (_) {
      verify(
        () => getOpportunities(query: 'accelerator', userId: _user.id),
      ).called(1);
    },
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
