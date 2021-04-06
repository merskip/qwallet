import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_source/Identifier.dart';
import 'data_source/Wallet.dart';
import 'utils/IterableFinding.dart';

class LocalUserPreferences {
  final ThemeMode themeMode;
  final Locale? locale;

  LocalUserPreferences({required this.themeMode, this.locale});

  factory LocalUserPreferences.empty() =>
      LocalUserPreferences(themeMode: ThemeMode.light, locale: null);
}

class LocalPreferences {
  static final _userPreferences = BehaviorSubject<LocalUserPreferences>(
    onListen: () => _emitUserPreferences(),
  );
  static get userPreferences =>
      _userPreferences.stream.doOnListen(() => _emitWalletsOrder());

  static final _walletsOrder = BehaviorSubject<List<Identifier<Wallet>>>(
    onListen: () => _emitWalletsOrder(),
  );

  static get walletsOrder => _walletsOrder.stream;

  static Future<void> setOrderWallets(
      List<Identifier<Wallet>> walletIds) async {
    final preferences = await SharedPreferences.getInstance();
    final walletOrder = walletIds.map((w) => w.toString()).toList();
    preferences.setStringList("walletsOrder", walletOrder);
    _walletsOrder.add(walletIds);
  }

  static void _emitUserPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final themeMode = _userThemeMode(preferences);
    final locale = _userLocaleOrNull(preferences);
    _userPreferences
        .add(LocalUserPreferences(themeMode: themeMode, locale: locale));
  }

  static void _emitWalletsOrder() async {
    final preferences = await SharedPreferences.getInstance();
    final walletsOrderIds = preferences.containsKey("walletsOrder")
        ? preferences.getStringList("walletsOrder")!
        : <String>[];
    final walletsOrder = walletsOrderIds
        .map((id) => Identifier.tryParse<Wallet>(id))
        .filterNonNull()
        .toList();
    _walletsOrder.add(walletsOrder);
  }

  static setUserThemeMode(ThemeMode themeMode) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString("user.themeMode", themeMode.toString());
    final locale = _userLocaleOrNull(preferences);
    _userPreferences
        .add(LocalUserPreferences(themeMode: themeMode, locale: locale));
  }

  static setUserLocale(Locale locale) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString("user.locale", locale.toString());
    final themeMode = _userThemeMode(preferences);
    _userPreferences
        .add(LocalUserPreferences(themeMode: themeMode, locale: locale));
  }

  static ThemeMode _userThemeMode(SharedPreferences preferences) =>
      preferences.containsKey("user.themeMode")
          ? _parseThemeMode(preferences.getString("user.themeMode")!)
          : LocalUserPreferences.empty().themeMode;

  static Locale? _userLocaleOrNull(SharedPreferences preferences) =>
      preferences.containsKey("user.locale")
          ? _parseLocale(preferences.getString("user.locale")!)
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
    if (locale.contains("_")) {
      final chunks = locale.split("_");
      return Locale(chunks[0], chunks[1]);
    } else {
      return Locale(locale);
    }
  }
}
