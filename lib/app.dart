import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/catalog.dart';
import 'core/theme.dart';
import 'features/auth/auth_pages.dart';
import 'features/home/shell_page.dart';
import 'features/browse/browse_pages.dart';
import 'features/live/live_pages.dart';
import 'features/live/dashboard_pages.dart';
import 'features/profile/profile_pages.dart';

class BeatrixApp extends StatelessWidget {
  const BeatrixApp({super.key, required this.state});
  final AppState state;
  static final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: AnimatedBuilder(
      animation: state,
      builder: (context, _) => MaterialApp(
        title: 'Beatrix',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: beatrixTheme(false),
        darkTheme: beatrixTheme(true),
        themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: state.signedIn ? '/home' : '/onboarding',
        onGenerateRoute: (settings) {
          final page = switch (settings.name) {
            '/onboarding' => const OnboardingPage(),
            '/login' => const AuthPage(),
            '/register' => const AuthPage(register: true),
            '/success' => const SuccessPage(),
            '/home' => const ShellPage(),
            '/discover' => const ShellPage(initialTab: 1),
            '/following' => const ShellPage(initialTab: 2),
            '/profile' => const ShellPage(initialTab: 3),
            '/search' => const SearchPage(),
            '/games' => const CatalogPage(kind: 'games'),
            '/streamers' => const CatalogPage(kind: 'streamers'),
            '/streams' => CatalogPage(
              kind: 'streams',
              category: settings.arguments as String?,
            ),
            '/category' => CategoryPage(
              game: settings.arguments as Game? ?? Catalog.games[1],
            ),
            '/streamer' => StreamerPage(
              name: settings.arguments as String? ?? 'Shroud',
            ),
            '/event' => const EventPage(),
            '/stream' => StreamPage(
              stream: settings.arguments as Stream? ?? Catalog.streams[0],
            ),
            '/fullscreen' => FullscreenPage(
              stream: settings.arguments as Stream? ?? Catalog.streams[0],
            ),
            '/leaderboard' => const LeaderboardPage(),
            '/dashboard' => const DashboardPage(),
            '/edit-live' => const EditLivePage(),
            '/settings' => const SettingsPage(),
            '/edit-profile' => const EditProfilePage(),
            '/account' => const EditProfilePage(account: true),
            '/wallet' => const WalletPage(),
            '/gifts' => const GiftCentrePage(),
            '/videos' => const VideosPage(),
            '/help' => const InfoPage(kind: 'help'),
            '/support' => const InfoPage(kind: 'support'),
            '/about' => const InfoPage(kind: 'about'),
            '/privacy' => const InfoPage(kind: 'privacy'),
            '/notifications' => const InfoPage(kind: 'notifications'),
            _ => const OnboardingPage(),
          };
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => page,
          );
        },
        builder: (context, child) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.orientationOf(context) == Orientation.landscape
                  ? double.infinity
                  : 600,
            ),
            child: child!,
          ),
        ),
      ),
    ),
  );
}
