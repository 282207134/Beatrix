import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beatrix/app.dart';
import 'package:beatrix/core/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Jakarta',
    )..addFont(rootBundle.load('assets/fonts/Jakarta-Regular.ttf'))).load();
  });
  testWidgets('login validates then enters home, discovery and profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    await tester.pumpWidget(BeatrixApp(state: state));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your username'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('Username')), 'demo');
    await tester.enterText(find.byKey(const ValueKey('Password')), '123456');
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();
    expect(state.signedIn, isTrue);
    expect(find.text('Today Top Stream'), findsOneWidget);
    await tester.tap(find.text('Discover').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
