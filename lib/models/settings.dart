import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/pages/settings_page.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.g.dart';
part 'settings.freezed.dart';

@freezed
class SettingsModel with _$SettingsModel {
  const SettingsModel._();
  const factory SettingsModel({
    // Theme
    @Default(UITheme.system) UITheme uiTheme,
    @Default(ColorTheme.system) ColorTheme colorTheme,
    // Map
    @Default(false) bool retinaMode,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}

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

enum ColorTheme implements SelectionOption<Brightness?> {
  system(displayName: "System", value: null),
  light(displayName: "Light", value: Brightness.light),
  dark(displayName: "Dark", value: Brightness.dark);

  @override final String displayName;
  @override final Brightness? value;
  const ColorTheme({
    required this.displayName,
    required this.value
  });
}
