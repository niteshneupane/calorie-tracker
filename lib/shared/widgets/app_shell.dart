part of '../../app.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    this.showBottomNav = true,
    this.floatingActionButton,
  });

  final Widget child;
  final int currentIndex;
  final bool showBottomNav;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                final route = [
                  RouteNames.today,
                  RouteNames.history,
                  RouteNames.foods,
                  RouteNames.profile,
                ][index];
                if (index != currentIndex) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today_rounded),
                  label: 'Today',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  label: 'Foods',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
