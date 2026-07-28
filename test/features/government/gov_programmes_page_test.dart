import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fundahub/features/government/domain/entities/gov_programme.dart';
import 'package:fundahub/features/government/domain/repositories/government_repository.dart';
import 'package:fundahub/features/government/domain/usecases/government_usecases.dart';
import 'package:fundahub/features/government/presentation/pages/gov_programmes_page.dart';
import 'package:fundahub/injection/injection.dart';

class MockGovernmentRepository extends Mock implements GovernmentRepository {}

void main() {
  late MockGovernmentRepository repository;

  setUp(() {
    repository = MockGovernmentRepository();
    sl.registerSingleton<GetGovProgrammes>(GetGovProgrammes(repository));
  });

  testWidgets('renders government programmes from the repository', (
    tester,
  ) async {
    when(
      () => repository.getProgrammes(category: any(named: 'category')),
    ).thenAnswer(
      (_) async => const [
        GovProgramme(
          id: '1',
          title: 'National Youth Entrepreneurship Fund',
          issuer: 'Ministry of Trade and Industrialization',
          amount: '₦5,000,000',
          deadlineLabel: '14 Days Left',
          tags: ['Grant', 'Tech'],
        ),
        GovProgramme(
          id: '2',
          title: 'Agribusiness Productivity Enhancement Scheme',
          issuer: 'Ministry of Agriculture',
          amount: '₦2,500,000',
          deadlineLabel: 'Closed',
          closed: true,
          tags: ['Loan', 'Agri'],
        ),
      ],
    );

    await tester.pumpWidget(const MaterialApp(home: GovProgrammesPage()));
    await tester.pumpAndSettle();

    expect(find.text('National Youth Entrepreneurship Fund'), findsOneWidget);
    expect(
      find.text('Agribusiness Productivity Enhancement Scheme'),
      findsOneWidget,
    );
    expect(find.text('Apply Now →'), findsOneWidget); // open programme
    expect(find.text('Viewing Only'), findsOneWidget); // closed programme
  });

  testWidgets('shows empty message when a category has no programmes', (
    tester,
  ) async {
    when(
      () => repository.getProgrammes(category: any(named: 'category')),
    ).thenAnswer((_) async => const <GovProgramme>[]);

    await tester.pumpWidget(const MaterialApp(home: GovProgrammesPage()));
    await tester.pumpAndSettle();

    expect(find.text('No programmes in this category.'), findsOneWidget);
  });
}
