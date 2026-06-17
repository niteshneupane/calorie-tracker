import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferences {
  const LocalPreferences(this._prefs);

  final SharedPreferences _prefs;
  static const _onboardingCompleteKey = 'onboarding_complete';

  bool get onboardingComplete =>
      _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_onboardingCompleteKey, value);
}
