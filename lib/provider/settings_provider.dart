import 'dart:async';

import 'package:forest_park_reports/model/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  SettingsModel build() {
    // Load the default settings immediately and fetch settings from
    // shared preferences in background.
    _fetch();
    return SettingsModel.fromJson({});
  }
  Future<void> update(SettingsModel settings) async {
    state = settings;
    final sp = await ref.read(sharedPreferencesProvider.future);
    state.persistToSharedPreferences(sp);
  }
  Future<void> _fetch() async {
    final sp = await ref.read(sharedPreferencesProvider.future);
    state = SettingsModel.fromSharedPreferences(sp);
  }
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}
