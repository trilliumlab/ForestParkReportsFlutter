import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/page/settings_page/selection_setting_widget.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings.g.dart';
part 'settings.freezed.dart';

@freezed
class SettingsModel with _$SettingsModel {
  const SettingsModel._();
  const factory SettingsModel({
    // Theme
    @Default(UITheme.system) required UITheme uiTheme,
    @Default(ColorTheme.system) required ColorTheme colorTheme,
    // Map
    @Default(false) required bool retinaMode,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  /// Creates a new [SettingsModel] from the settings persisted to [SharedPreferences]
  factory SettingsModel.fromSharedPreferences(SharedPreferences sp) {
    return SettingsModel.fromJson({
      for (final key in sp.getKeys())
        if (key.startsWith("setting."))
          key.replaceFirst("setting.", ""): sp.get(key),
    });
  }

  /// Persists the settings to [SharedPreferences]
  void persistToSharedPreferences(SharedPreferences sp) {
    sp.setString("setting.uiTheme", uiTheme.name);
    sp.setString("setting.colorTheme", colorTheme.name);
    sp.setBool("setting.retinaMode", retinaMode);
  }
}

/// An option for [SelectionSettingWidget]
abstract interface class SelectionOption<T> {
  String get displayName;
  T get value;
}

enum UITheme implements SelectionOption<TargetPlatform?> {
  system(displayName: "System", value: null),
  cupertino(displayName: "iOS", value: TargetPlatform.iOS),
  material(displayName: "Android", value: TargetPlatform.android);

  @override final String displayName;
  @override final TargetPlatform? value;
  const UITheme({
    required this.displayName,
    required this.value
  });
}

enum ColorTheme implements SelectionOption<ThemeMode> {
  system(displayName: "System", value: ThemeMode.system),
  light(displayName: "Light", value: ThemeMode.light),
  dark(displayName: "Dark", value: ThemeMode.dark);

  @override final String displayName;
  @override final ThemeMode value;
  const ColorTheme({
    required this.displayName,
    required this.value
  });
}
