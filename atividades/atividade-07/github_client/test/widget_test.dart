import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/main.dart';

void main() {
  testWidgets('shows GitHub login screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('GitHub Login'), findsOneWidget);
    expect(find.text('Login to GitHub'), findsOneWidget);
  });
}
