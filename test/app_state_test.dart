import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beatrix/core/app_state.dart';
import 'package:beatrix/core/catalog.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('follows, theme and profile survive reloading', () async {
    final state = await AppState.load();
    await state.toggleFollow('Chappy');
    await state.toggleFollow('Shroud');
    await state.setDark(true);
    await state.saveProfile('Beatrix Fan', 'Hello community');
    await state.saveEmail('fan@example.com');
    await state.login();
    final restored = await AppState.load();
    expect(restored.following, contains('Chappy'));
    expect(restored.following, isNot(contains('Shroud')));
    expect(restored.nickname, 'Beatrix Fan');
    expect(restored.email, 'fan@example.com');
    expect(restored.dark, isTrue);
    expect(restored.signedIn, isTrue);
  });
  test(
    'gift ledger persists and insufficient funds cannot go negative',
    () async {
      final state = await AppState.load();
      expect(await state.sendGift(Catalog.gifts.first, 'Shroud'), isTrue);
      expect(state.balance, 3100);
      expect(
        await state.sendGift(const Gift('Too expensive', 4000), 'Shroud'),
        isFalse,
      );
      expect(state.balance, 3100);
      final restored = await AppState.load();
      expect(restored.balance, 3100);
      expect(restored.giftHistory, hasLength(1));
    },
  );
  test('search history deduplicates and caps at eight entries', () async {
    final state = await AppState.load();
    for (int i = 0; i < 10; i++) {
      await state.search('Game $i');
    }
    await state.search('Game 5');
    expect(state.searches.length, 8);
    expect(state.searches.first, 'Game 5');
    await state.clearSearches();
    expect((await AppState.load()).searches, isEmpty);
  });
  test('empty chat is ignored and logout ends local stream', () async {
    final state = await AppState.load();
    final count = state.messages.length;
    state.sendMessage('  ');
    expect(state.messages.length, count);
    state.sendMessage(' hello ');
    expect(state.messages.last.$2, 'hello');
    state.toggleStreaming();
    await state.login();
    await state.logout();
    expect(state.streaming, isFalse);
    expect((await AppState.load()).signedIn, isFalse);
  });
  test('malformed saved JSON falls back without crashing', () async {
    SharedPreferences.setMockInitialValues({'beatrix.v1': 'invalid json'});
    expect((await AppState.load()).balance, 3110);
  });
  test(
    'remember me controls saved session without losing local profile',
    () async {
      final state = await AppState.load();
      await state.login(remember: false);
      expect(state.signedIn, isTrue);
      expect((await AppState.load()).signedIn, isFalse);
      await state.login(remember: true);
      expect((await AppState.load()).signedIn, isTrue);
    },
  );
  test('all stream preferences survive reloading', () async {
    final state = await AppState.load();
    await state.saveStreamPreferences(
      'Community night',
      'Esport',
      'Overwatch 2',
      '日本語',
    );
    final restored = await AppState.load();
    expect(restored.streamTitle, 'Community night');
    expect(restored.streamCategory, 'Esport');
    expect(restored.streamGame, 'Overwatch 2');
    expect(restored.streamLanguage, '日本語');
  });
}
