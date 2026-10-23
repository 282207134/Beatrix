import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beatrix/main.dart' as app;
import 'package:beatrix/app.dart';
import 'package:beatrix/core/app_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  testWidgets('end-to-end flows and screen capture', (tester) async {
    await (await SharedPreferences.getInstance()).clear();
    await app.main();
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    Future<void> snap(String name) async {
      await tester.pumpAndSettle();
      // Allow asset decoding, pointer fade and Android rasterization to finish.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull, reason: name);
      await binding.takeScreenshot(name);
    }

    Future<void> page(String route, String name, {Object? args}) async {
      BeatrixApp.navigatorKey.currentState!.pushNamed(route, arguments: args);
      await snap(name);
    }

    void back() => BeatrixApp.navigatorKey.currentState!.pop();

    await snap('01-onboarding');
    await tester.tap(find.text('Register'));
    await snap('02-register');
    await tester.enterText(
      find.byKey(const ValueKey('Username')),
      'BeatrixFan',
    );
    await tester.enterText(
      find.byKey(const ValueKey('Email')),
      'fan@example.com',
    );
    await tester.enterText(find.byKey(const ValueKey('Password')), 'demo123');
    await tester.tap(find.byType(Checkbox));
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await snap('03-register-success');
    await tester.tap(find.text('Let’s Explore'));
    await snap('04-home');
    await tester.tap(find.text('Discover').last);
    await snap('05-discover');
    await tester.tap(find.text('Favourite').last);
    await snap('06-continue-watching');
    await tester.tap(find.text('Following').last);
    await snap('07-following');
    await tester.tap(find.text('Profile').last);
    await snap('08-profile');

    await page('/search', '09-search');
    await tester.enterText(find.byKey(const ValueKey('search-input')), 'Sh');
    await snap('10-search-suggestions');
    await tester.enterText(
      find.byKey(const ValueKey('search-input')),
      'Valorant',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await snap('11-search-top');
    for (final item in [
      ('Channels', '12-search-channels'),
      ('Categories', '13-search-categories'),
      ('Videos', '14-search-videos'),
    ]) {
      await tester.tap(find.text(item.$1).first);
      await snap(item.$2);
    }
    back();
    await tester.pumpAndSettle();

    await page('/stream', '15-stream');
    final state = AppScope.of(
      tester.element(find.byKey(const ValueKey('stream-follow'))),
    );
    final wasFollowing = state.following.contains('Shroud');
    await tester.tap(find.byKey(const ValueKey('stream-follow')));
    await tester.pumpAndSettle();
    expect(state.following.contains('Shroud'), !wasFollowing);
    await tester.enterText(
      find.byKey(const ValueKey('chat-input')),
      'Great play!',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(state.messages.last.$2, 'Great play!');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Send gift'));
    await snap('16-gift-panel');
    final balance = state.balance;
    await tester.tap(find.text('Heart'));
    await tester.pumpAndSettle();
    expect(state.balance, balance - 10);
    back();
    await tester.pumpAndSettle();
    await page('/leaderboard', '17-leaderboard');
    back();
    await tester.pumpAndSettle();
    back();
    await tester.pumpAndSettle();

    await page('/category', '18-category-live');
    for (final item in [
      ('Videos', '19-category-videos'),
      ('Clips', '20-category-clips'),
      ('Events', '21-category-events'),
    ]) {
      await tester.tap(find.text(item.$1).first);
      await snap(item.$2);
    }
    back();
    await tester.pumpAndSettle();
    await page('/streamer', '22-streamer');
    await tester.tap(find.text('Clips').first);
    await snap('23-streamer-clips');
    await tester.tap(find.text('About').first);
    await snap('24-streamer-about');
    back();
    await tester.pumpAndSettle();

    for (final item in [
      ('/event', '25-event'),
      ('/games', '26-games'),
      ('/streamers', '27-streamers'),
      ('/streams', '28-streams'),
      ('/settings', '29-settings'),
      ('/edit-profile', '30-edit-profile'),
      ('/account', '31-edit-account'),
      ('/wallet', '32-wallet'),
      ('/gifts', '33-gift-centre'),
      ('/videos', '34-my-videos'),
      ('/help', '35-help'),
      ('/support', '36-support'),
      ('/about', '37-about'),
      ('/privacy', '38-privacy'),
      ('/notifications', '39-notifications'),
      ('/dashboard', '40-dashboard'),
      ('/edit-live', '41-edit-live'),
      ('/login', '42-login'),
    ]) {
      await page(item.$1, item.$2);
      back();
      await tester.pumpAndSettle();
    }
    await state.setDark(true);
    await page('/home', '43-home-dark');
    back();
    await tester.pumpAndSettle();
    await page('/discover', '44-discover-dark');
    back();
    await tester.pumpAndSettle();
    await page('/stream', '45-stream-dark');
    back();
    await tester.pumpAndSettle();
    await page('/profile', '46-profile-dark');
    back();
    await tester.pumpAndSettle();
    await state.setDark(false);
    await page('/fullscreen', '47-fullscreen');
    back();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
