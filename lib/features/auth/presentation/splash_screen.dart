part of '../../../app.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 850), () async {
      if (!mounted) return;
      if (AppConfig.hasSupabaseConfig &&
          Supabase.instance.client.auth.currentSession != null) {
        final token = Supabase.instance.client.auth.currentSession!.accessToken;
        await ref.read(tokenStorageProvider).saveToken(token);
        await ref.read(authControllerProvider.notifier).signInMock();
        final profile = await ref
            .read(profileRepositoryProvider)
            .getProfile()
            .catchError((_) => const UserProfile());
        if (profile.dailyCalorieGoal != null) {
          await ref.read(authControllerProvider.notifier).completeOnboarding();
        }
      }
      if (!mounted) return;
      final auth = ref.read(authControllerProvider);
      final route = !auth.isAuthenticated
          ? RouteNames.signIn
          : auth.onboardingComplete
          ? RouteNames.today
          : RouteNames.onboardingProfile;
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 76,
                color: AppColors.primary,
              ),
              SizedBox(height: 18),
              Text(AppConstants.appName, style: AppTextStyles.title),
              SizedBox(height: 6),
              Text(AppConstants.tagline, style: AppTextStyles.muted),
            ],
          ),
        ),
      ),
    );
  }
}
