import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';

/// Offline demo store. Passwords and authentication tokens are never saved.
class AppState extends ChangeNotifier {
  AppState(this._preferences);
  final SharedPreferences _preferences;
  bool dark = false, signedIn = false, streaming = false;
  bool _rememberSession = true;
  String streamCategory = 'Gaming',
      streamGame = 'Valorant',
      streamLanguage = 'English';
  String nickname = 'Guerry',
      bio = 'Create amazing gaming experience!',
      email = 'guerry@example.com',
      streamTitle = 'Let’s play Valorant together!';
  int balance = 3110;
  final Set<String> following = {'Shroud', 'Guerry'};
  final List<String> searches = ['Valorant', 'Shroud', 'Overwatch 2'];
  final List<String> giftHistory = [];
  final List<(String, String)> messages = [
    ('Jyane', 'Wow, this is really epic'),
    ('MatthewG', 'I’ll be there in 2 mins'),
    ('Josh', 'Haha that’s terrifying'),
    ('Klea', 'Haha oh man'),
    ('millan_sue', 'just ideas for next time'),
    ('nobarainc', 'perfect!'),
    ('lootbox', 'aww'),
    ('Menaruchan', 'omg, this is amazing'),
  ];
  static Future<AppState> load() async {
    final state = AppState(await SharedPreferences.getInstance());
    try {
      final raw = state._preferences.getString('beatrix.v1');
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        state.dark = data['dark'] as bool? ?? false;
        state.signedIn = data['signedIn'] as bool? ?? false;
        state.nickname = data['nickname'] as String? ?? state.nickname;
        state.bio = data['bio'] as String? ?? state.bio;
        state.email = data['email'] as String? ?? state.email;
        state.streamTitle = data['streamTitle'] as String? ?? state.streamTitle;
        state.streamCategory = data['streamCategory'] as String? ?? 'Gaming';
        state.streamGame = data['streamGame'] as String? ?? 'Valorant';
        state.streamLanguage = data['streamLanguage'] as String? ?? 'English';
        state.balance = data['balance'] as int? ?? 3110;
        state.following
          ..clear()
          ..addAll(
            List<String>.from(data['following'] ?? ['Shroud', 'Guerry']),
          );
        state.searches
          ..clear()
          ..addAll(List<String>.from(data['searches'] ?? []));
        state.giftHistory.addAll(List<String>.from(data['gifts'] ?? []));
      }
    } on FormatException {
      /* Invalid saved JSON uses demo defaults. */
    } on TypeError {
      /* Incompatible saved data uses demo defaults. */
    }
    return state;
  }

  Future<void> _save() async {
    notifyListeners();
    await _preferences.setString(
      'beatrix.v1',
      jsonEncode({
        'dark': dark,
        'signedIn': signedIn && _rememberSession,
        'nickname': nickname,
        'bio': bio,
        'email': email,
        'streamTitle': streamTitle,
        'streamCategory': streamCategory,
        'streamGame': streamGame,
        'streamLanguage': streamLanguage,
        'balance': balance,
        'following': following.toList(),
        'searches': searches,
        'gifts': giftHistory,
      }),
    );
  }

  Future<void> setDark(bool value) {
    dark = value;
    return _save();
  }

  Future<void> login({bool remember = true}) {
    _rememberSession = remember;
    signedIn = true;
    return _save();
  }

  Future<void> logout() {
    signedIn = false;
    streaming = false;
    return _save();
  }

  Future<void> toggleFollow(String creator) {
    if (!following.remove(creator)) {
      following.add(creator);
    }
    return _save();
  }

  Future<void> saveProfile(String name, String description) {
    nickname = name.trim();
    bio = description.trim();
    return _save();
  }

  Future<void> saveEmail(String value) {
    email = value.trim();
    return _save();
  }

  Future<void> saveStreamPreferences(
    String value,
    String category,
    String game,
    String language,
  ) {
    streamTitle = value.trim();
    streamCategory = category;
    streamGame = game;
    streamLanguage = language;
    return _save();
  }

  Future<void> search(String query) {
    final value = query.trim();
    if (value.isEmpty) {
      return Future.value();
    }
    searches
      ..remove(value)
      ..insert(0, value);
    if (searches.length > 8) {
      searches.removeLast();
    }
    return _save();
  }

  Future<void> clearSearches() {
    searches.clear();
    return _save();
  }

  Future<bool> sendGift(Gift gift, String creator) async {
    if (balance < gift.cost) {
      return false;
    }
    balance -= gift.cost;
    giftHistory.insert(0, '${gift.name} → $creator · ${gift.cost} diamonds');
    await _save();
    return true;
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) {
      return;
    }
    messages.add((nickname, text.trim()));
    notifyListeners();
  }

  void toggleStreaming() {
    streaming = !streaming;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
