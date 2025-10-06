import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/app_theme.dart';
import 'features/home/home_page.dart';
import 'features/prashna/prashna_list_page.dart';
import 'features/prashna/prashna_order_page.dart';
import 'features/pooja/pooja_list_page.dart';
import 'features/pooja/pooja_order_page.dart';
import 'features/profile/profile_page.dart';
import 'features/settings/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _index = 0;

  late final _router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) {
                setState(() => _index = i);
                switch (i) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/profile');
                    break;
                  case 2:
                    context.go('/settings');
                    break;
                }
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
            routes: [
              GoRoute(
                path: 'prashna',
                pageBuilder: (context, state) => const NoTransitionPage(child: PrashnaListPage()),
                routes: [
                  GoRoute(
                    path: ':orderId',
                    builder: (context, state) => PrashnaOrderPage(orderId: state.pathParameters['orderId']!),
                  ),
                ],
              ),
              GoRoute(
                path: 'pooja',
                pageBuilder: (context, state) => const NoTransitionPage(child: PoojaListPage()),
                routes: [
                  GoRoute(
                    path: ':orderId',
                    builder: (context, state) => PoojaOrderPage(orderId: state.pathParameters['orderId']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(path: '/profile', pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage())),
          GoRoute(path: '/settings', pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage())),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
