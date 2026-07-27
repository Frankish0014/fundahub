import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fundahub/features/community/domain/entities/community_post.dart';
import 'package:fundahub/features/community/domain/repositories/community_repository.dart';
import 'package:fundahub/features/community/domain/usecases/community_usecases.dart';
import 'package:fundahub/features/community/presentation/pages/community_home_page.dart';
import 'package:fundahub/injection/injection.dart';

class MockCommunityRepository extends Mock implements CommunityRepository {}

void main() {
  late MockCommunityRepository repository;

  setUp(() {
    repository = MockCommunityRepository();
    // The page resolves GetCommunityPosts from the service locator.
    sl.registerSingleton<GetCommunityPosts>(GetCommunityPosts(repository));
  });

  testWidgets('renders community posts from the repository', (tester) async {
    when(() => repository.getPosts(sector: any(named: 'sector'))).thenAnswer(
      (_) async => const [
        CommunityPost(
          id: '1',
          authorName: 'Amara Okafor',
          authorMeta: '2h ago • Founder, GreenRoots',
          body: 'Just closed our first round of seed funding!',
          tags: ['#AgriTech'],
          likes: 124,
          commentCount: 3,
        ),
        CommunityPost(
          id: '2',
          authorName: 'Kofi Mensah',
          authorMeta: '5h ago • Logistics Strategist',
          body: 'Anyone solving last-mile delivery challenges in Accra?',
          tags: ['#IoT'],
          likes: 89,
        ),
      ],
    );

    await tester.pumpWidget(const MaterialApp(home: CommunityHomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Amara Okafor'), findsOneWidget);
    expect(find.text('Kofi Mensah'), findsOneWidget);
    expect(find.textContaining('seed funding'), findsOneWidget);
    verify(() => repository.getPosts(sector: any(named: 'sector'))).called(1);
  });

  testWidgets('shows a loading indicator before posts arrive', (tester) async {
    when(() => repository.getPosts(sector: any(named: 'sector'))).thenAnswer((
      _,
    ) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return const <CommunityPost>[];
    });

    await tester.pumpWidget(const MaterialApp(home: CommunityHomePage()));
    await tester.pump(); // first frame: still loading

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('shows an error state with retry on failure', (tester) async {
    when(
      () => repository.getPosts(sector: any(named: 'sector')),
    ).thenThrow(Exception('network down'));

    await tester.pumpWidget(const MaterialApp(home: CommunityHomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}
