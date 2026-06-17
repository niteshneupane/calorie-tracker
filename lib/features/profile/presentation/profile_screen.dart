part of '../../../app.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    return AppShell(
      currentIndex: 3,
      child: profile.when(
        loading: () => const AppLoading(),
        error: (error, _) => Text(error.toString()),
        data: (user) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? 'AaharLog user',
                          style: AppTextStyles.cardTitle,
                        ),
                        Text(
                          user.email ?? 'Signed in with Supabase',
                          style: AppTextStyles.muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NutritionGoalCard(user: user),
            const SizedBox(height: 14),
            SettingsListTile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              onTap: () async {
                await ref.read(tokenStorageProvider).clear();
                if (AppConfig.hasSupabaseConfig) {
                  await Supabase.instance.client.auth.signOut();
                }
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.signIn,
                    (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
