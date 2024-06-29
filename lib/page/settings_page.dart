import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/model/settings.dart';
import 'package:forest_park_reports/page/settings_page/settings_page_scaffold.dart';
import 'package:forest_park_reports/page/settings_page/selection_setting_widget.dart';
import 'package:forest_park_reports/page/settings_page/toggle_setting_widget.dart';
import 'package:forest_park_reports/page/settings_page/button_setting_widget.dart';
import 'package:forest_park_reports/page/settings_page/setting_confirmation.dart';
import 'package:forest_park_reports/page/settings_page/settings_section.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:forest_park_reports/provider/hazard_photo_provider.dart';
import 'package:forest_park_reports/provider/settings_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SettingsPageScaffold(
      title: "Settings",
      previousPageTitle: "Home",
      children: [
        SettingsSection(
          label: "Theme",
          children: [
            /* FIXME: Currently the theme can't update when a custom platform is set...
             * Flutter Platform Widgets bug
             */
            // SelectionSettingWidget(
            //   name: "UI Theme",
            //   pageTitle: "Settings",
            //   options: UITheme.values,
            //   selectedOption: settings.uiTheme,
            //   onSelection: (option) {
            //     PlatformProvider.of(context)?.changeToCupertinoPlatform();
            //     ref.read(settingsProvider.notifier).update(settings.copyWith(
            //       uiTheme: option,
            //     ));
            //   },
            // ),
            SelectionSettingWidget(
              name: "Color Theme",
              pageTitle: "Settings",
              options: ColorTheme.values,
              selectedOption: settings.colorTheme,
              onSelection: (option) {
                ref.read(settingsProvider.notifier).update(settings.copyWith(
                  colorTheme: option,
                ));
              },
            ),
          ],
        ),
        SettingsSection(
          label: "Map",
          children: [
            ToggleSettingWidget(
              name: "Retina Mode",
              value: settings.retinaMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).update(settings.copyWith(
                  retinaMode: value,
                ));
              },
            )
          ],
        ),
        SettingsSection(
          label: "Advanced",
          children: [
            ButtonSettingWidget(
              name: "Reset database",
              buttonStyle: ButtonSettingStyle.danger,
              confirmation: SettingConfirmation(
                  title: "Reset database?",
                  content: "All settings and offline reports will be lost."),
              onTap: () async {
                //  Delete database
                ref.read(forestParkDatabaseProvider.notifier).delete();
                // Delete cache
                final imageDir = (await ref.read(imageDirectoryProvider.future))!;
                await imageDir.delete(recursive: true);
              },
            )
          ],
        ),
      ],
    );
  }
}
