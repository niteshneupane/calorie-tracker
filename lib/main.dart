import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/storage/local_preferences.dart';
import 'features/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  if (AppConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }
  runApp(
    ProviderScope(
      overrides: [
        localPreferencesProvider.overrideWithValue(
          LocalPreferences(sharedPreferences),
        ),
      ],
      child: const AaharLogApp(),
    ),
  );
}
