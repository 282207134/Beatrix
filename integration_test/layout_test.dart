import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:beatrix/app.dart';
import 'package:beatrix/core/app_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  testWidgets('all principal routes fit the phone in both themes', (
    tester,
  ) async {
    final state = await AppState.load();
    await tester.pumpWidget(BeatrixApp(state: state));
    await tester.pumpAndSettle();
    for (final dark in [false, true]) {
      await state.setDark(dark);
      for (final route in [
        '/home',
        '/discover',
        '/following',
        '/profile',
        '/search',
        '/games',
        '/streamers',
        '/streams',
        '/category',
        '/streamer',
        '/event',
        '/stream',
        '/leaderboard',
        '/dashboard',
        '/edit-live',
        '/settings',
        '/edit-profile',
        '/account',
        '/wallet',
        '/gifts',
        '/videos',
        '/help',
        '/support',
        '/about',
        '/privacy',
        '/notifications',
        '/register',
        '/success',
      ]) {
        BeatrixApp.navigatorKey.currentState!.pushNamed(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route / dark=$dark');
        BeatrixApp.navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
      }
    }
    await state.setDark(false);
  });
}
