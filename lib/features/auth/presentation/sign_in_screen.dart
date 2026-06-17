part of '../../../app.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (AppConfig.hasSupabaseConfig) {
      return const SupabaseSignInBody();
    }

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 52,
            color: AppColors.primary,
          ),
          const SizedBox(height: 18),
          const Text(AppConstants.appName, style: AppTextStyles.title),
          const SizedBox(height: 8),
          const Text(
            'Log meals in your own words.',
            style: TextStyle(fontSize: 18, color: AppColors.muted),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Continue in mock mode',
            icon: Icons.mail_outline_rounded,
            onPressed: AppConfig.useMockData
                ? () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .signInMock();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        RouteNames.onboardingProfile,
                      );
                    }
                  }
                : null,
          ),
          const SizedBox(height: 18),
          Text(
            !AppConfig.hasSupabaseConfig
                ? 'Your food logs stay private. Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY to enable real sign-in.'
                : 'Your food logs stay private.',
            style: AppTextStyles.muted,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class SupabaseSignInBody extends StatelessWidget {
  const SupabaseSignInBody({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: ListView(
        children: const [
          SizedBox(height: 24),
          Icon(
            Icons.restaurant_menu_rounded,
            size: 52,
            color: AppColors.primary,
          ),
          SizedBox(height: 18),
          Text(AppConstants.appName, style: AppTextStyles.title),
          SizedBox(height: 8),
          Text(
            'Log meals in your own words.',
            style: TextStyle(fontSize: 18, color: AppColors.muted),
          ),
          SizedBox(height: 24),
          EmailOnlySupabaseForm(),
          SizedBox(height: 18),
          Text('Your food logs stay private.', style: AppTextStyles.muted),
        ],
      ),
    );
  }
}

class EmailOnlySupabaseForm extends ConsumerStatefulWidget {
  const EmailOnlySupabaseForm({super.key});

  @override
  ConsumerState<EmailOnlySupabaseForm> createState() =>
      _EmailOnlySupabaseFormState();
}

class _EmailOnlySupabaseFormState extends ConsumerState<EmailOnlySupabaseForm> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool signingUp = false;
  bool confirmationSent = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final supabase = Supabase.instance.client;
      AuthResponse response;
      if (signingUp) {
        response = await supabase.auth.signUp(
          email: email.text.trim(),
          password: password.text,
        );
        if (response.session == null) {
          setState(() => confirmationSent = true);
          return;
        }
      } else {
        response = await supabase.auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
      final token = response.session?.accessToken;
      if (token == null || token.isEmpty) {
        setState(() => confirmationSent = true);
        return;
      }
      await ref.read(tokenStorageProvider).saveToken(token);
      await ref.read(authControllerProvider.notifier).signInMock();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteNames.onboardingProfile);
    } on AuthException catch (exception) {
      setState(() => error = exception.message);
    } catch (exception) {
      setState(() => error = exception.toString());
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (confirmationSent) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 44),
            const SizedBox(height: 12),
            const Text('Check your email', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(
              'We sent a confirmation link to ${email.text.trim()}. After confirming, come back and sign in.',
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Back to sign in',
              secondary: true,
              onPressed: () => setState(() {
                confirmationSent = false;
                signingUp = false;
              }),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            signingUp ? 'Create account' : 'Sign in with email',
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: email,
            enabled: !loading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            enabled: !loading,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: loading
                ? 'Please wait...'
                : signingUp
                ? 'Sign up with Email'
                : 'Continue with Email',
            icon: Icons.arrow_forward_rounded,
            onPressed: loading ? null : submit,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: loading
                ? null
                : () {
                    setState(() {
                      signingUp = !signingUp;
                      confirmationSent = false;
                      error = null;
                    });
                  },
            child: Text(
              signingUp
                  ? 'Already have an account? Sign in'
                  : 'New to AaharLog? Create account',
            ),
          ),
        ],
      ),
    );
  }
}
