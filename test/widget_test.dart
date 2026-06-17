import 'package:aahar_log/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('moves from splash to sign in', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AaharLogApp()));

    expect(find.text('AaharLog'), findsOneWidget);
    expect(find.text('Track meals naturally'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(find.text('Log meals in your own words.'), findsOneWidget);
  });
}
