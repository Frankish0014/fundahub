import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fundahub/app.dart';
import 'package:fundahub/injection/injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  testWidgets('Welcome screen shows FundaHub brand', (tester) async {
    await tester.pumpWidget(const FundaHubApp());
    await tester.pumpAndSettle();

    expect(find.text('FundaHub'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
