import 'package:aahar_log/app.dart';
import 'package:aahar_log/core/storage/local_preferences.dart';
import 'package:aahar_log/features/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('moves from splash to sign in', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localPreferencesProvider.overrideWithValue(LocalPreferences(prefs)),
        ],
        child: const MyCalorieApp(),
      ),
    );

    expect(find.text('My Calorie'), findsOneWidget);
    expect(find.text('Track meals naturally'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(find.text('Log meals in your own words.'), findsOneWidget);
  });
}
