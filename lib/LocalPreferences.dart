import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  final ThemeMode themeMode;
  final Locale locale;

  UserPreferences({@required this.themeMode, this.locale});

  factory UserPreferences.empty() => UserPreferences(
    themeMode: ThemeMode.system,
    locale: null
  );
}

class LocalPreferences {

  static final _walletsOrder = StreamController<List<Wallet>>.broadcast();
  static final _userPreferences = StreamController<UserPreferences>.broadcast();

  static Future<void> orderWallets(List<Wallet> wallets) async {
    final preferences = await SharedPreferences.getInstance();
    final walletsOrderIds = wallets.map((wallet) => wallet.id).toList();
    preferences.setStringList("walletsOrder", walletsOrderIds);
    _walletsOrder.add(wallets);
  }

  static Stream<List<Wallet>> orderedWallets(Stream<List<Wallet>> wallets) {
    return MergeStream([_walletsOrder.stream, wallets])
        .asyncMap((wallets) async {
          final remainingWallets = List.of(wallets);

      final preferences = await SharedPreferences.getInstance();
      final walletsOrderIds = preferences.containsKey("walletsOrder") ? preferences.getStringList("walletsOrder") : [];

      final result = List<Wallet>();
      for (final walletId in walletsOrderIds) {
        final foundWallet = remainingWallets.firstWhere(
            (wallet) => wallet.id == walletId,
            orElse: () => null);
        if (foundWallet != null) {
          result.add(foundWallet);
          remainingWallets.remove(foundWallet);
        }
      }
      result.addAll(remainingWallets);
      return result;
    });
  }

  static Stream<UserPreferences> userPreferences() {
    SharedPreferences.getInstance().then((preferences) {
      final themeMode = _userThemeMode(preferences);
      final locale = _userLocaleOrNull(preferences);
      _userPreferences.add(UserPreferences(themeMode: themeMode, locale: locale));
    });
    return _userPreferences.stream;
  }

  static setUserThemeMode(ThemeMode themeMode) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString("user.themeMode", themeMode.toString());
    final locale = _userLocaleOrNull(preferences);
    _userPreferences.add(UserPreferences(themeMode: themeMode, locale: locale));
  }

  static ThemeMode _userThemeMode(SharedPreferences preferences) =>
      preferences.containsKey("user.themeMode")
          ? _parseThemeMode(preferences.getString("user.themeMode"))
          : UserPreferences.empty().themeMode;

  static Locale _userLocaleOrNull(SharedPreferences preferences) =>
      preferences.containsKey("user.locale")
          ? _parseLocale(preferences.getString("user.locale"))
          : null;

  static ThemeMode _parseThemeMode(String themeMode) {
    switch (themeMode) {
      case "ThemeMode.light":
        return ThemeMode.light;
      case "ThemeMode.dark":
        return ThemeMode.dark;
      case "ThemeMode.system":
      default:
        return ThemeMode.system;
    }
  }

  static Locale _parseLocale(String locale) {
    if (locale.contains("-")) {
      final chunks = locale.split("-");
      return Locale(chunks[0], chunks[1]);
    }
    else {
      return Locale(locale);
    }
  }
}

