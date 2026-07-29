import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fundahub/core/session/current_user_controller.dart';
import 'package:fundahub/features/auth/domain/entities/user_profile.dart';
import 'package:fundahub/features/auth/domain/usecases/auth_usecases.dart';
import 'package:fundahub/features/home/presentation/bloc/home_bloc.dart';
import 'package:fundahub/features/opportunities/domain/entities/opportunity.dart';
import 'package:fundahub/features/opportunities/domain/usecases/opportunity_usecases.dart';

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockGetRecommendedOpportunities extends Mock
    implements GetRecommendedOpportunities {}

const _user = UserProfile(
  id: 'uid-1',
  fullName: 'Tifare Kaseke',
  email: 'tifare@example.com',
  role: 'Student Entrepreneur',
  interests: ['Technology'],
);

const _opportunity = Opportunity(
  id: 'op-1',
  title: 'Tony Elumelu Foundation Grant',
  organization: 'TEF',
  type: OpportunityType.grant,
  amountLabel: '\$5,000',
  tags: ['Grant'],
  daysLeft: 12,
);

void main() {
  late MockGetCurrentUser getCurrentUser;
  late MockGetRecommendedOpportunities getRecommended;
  late CurrentUserController currentUser;

  setUp(() {
    getCurrentUser = MockGetCurrentUser();
    getRecommended = MockGetRecommendedOpportunities();
    currentUser = CurrentUserController();
  });

  HomeBloc buildBloc() => HomeBloc(
    getCurrentUser: getCurrentUser,
    getRecommended: getRecommended,
    currentUser: currentUser,
  );

  blocTest<HomeBloc, HomeState>(
    'emits [loading, success] with the user and recommended opportunities '
    'on HomeStarted',
    setUp: () {
      when(() => getCurrentUser()).thenAnswer((_) async => _user);
      when(
        () => getRecommended(
          interests: any(named: 'interests'),
          role: any(named: 'role'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => const [_opportunity]);
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const HomeStarted()),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      // currentUser.apply(user) inside _onStarted fires the external-sync
      // listener before getRecommended() resolves, so the user arrives one
      // emission ahead of the recommended list.
      const HomeState(status: HomeStatus.loading, user: _user),
      const HomeState(
        status: HomeStatus.success,
        user: _user,
        recommended: [_opportunity],
      ),
    ],
    verify: (_) {
      verify(
        () => getRecommended(
          interests: _user.interests,
          role: _user.role,
          userId: _user.id,
        ),
      ).called(1);
    },
  );

  blocTest<HomeBloc, HomeState>(
    'emits [loading, failure] when the repository throws',
    setUp: () {
      when(() => getCurrentUser()).thenThrow(Exception('offline'));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const HomeStarted()),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'syncs state.user when CurrentUserController changes externally',
    setUp: () {
      when(() => getCurrentUser()).thenAnswer((_) async => null);
      when(
        () => getRecommended(
          interests: any(named: 'interests'),
          role: any(named: 'role'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => const []);
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const HomeStarted());
      await Future<void>.delayed(Duration.zero);
      currentUser.apply(_user);
    },
    skip: 2,
    expect: () => [const HomeState(status: HomeStatus.success, user: _user)],
  );
}
