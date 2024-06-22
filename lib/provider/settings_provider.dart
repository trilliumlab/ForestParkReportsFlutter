import 'package:forest_park_reports/model/settings.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  static final store = StoreRef<String, dynamic>("settings");

  @override
  SettingsModel build() {
    // Load the default settings immediately and fetch settings from db in background.
    _fetch();
    return SettingsModel.fromJson({});
  }
  void update(SettingsModel settings) {
    _persist(state, settings);
    state = settings;
  }

  Future<void> _fetch() async {
    final db = await ref.watch(forestParkDatabaseProvider.future);

    // Each setting is stored in it's own record - convert to a map and parse to SettingsModel
    final settingsMap = {
      for (final setting in await store.find(db))
        setting.key: setting.value
    };
    state = SettingsModel.fromJson(settingsMap);
  }
  Future<void> _persist(SettingsModel previous, SettingsModel next) async {
    final db = await ref.watch(forestParkDatabaseProvider.future);

    // Save each new setting to db
    final previousMap = previous.toJson();
    final nextMap = next.toJson();

    db.transaction((txn) async {
      for (final setting in nextMap.entries) {
        if (!previousMap.containsKey(setting.key) || setting.value != previousMap[setting.key]) {
          // Then this value has been updated and needs to be persisted
          await store.record(setting.key).put(txn, setting.value);
        }
      }
    });
  }
}
