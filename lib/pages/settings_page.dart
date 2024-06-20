import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/models/settings.dart';
import 'package:forest_park_reports/providers/database_provider.dart';
import 'package:forest_park_reports/providers/settings_provider.dart';
import 'package:forest_park_reports/widgets/animated_app_bar_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPageScaffold extends StatefulWidget {
  final List<Widget> children;
  final String title;
  final String? previousPageTitle;
  const SettingsPageScaffold({super.key, required this.children, required this.title, this.previousPageTitle});

  @override
  State<SettingsPageScaffold> createState() => _SettingsPageScaffoldState();
}

class _SettingsPageScaffoldState extends State<SettingsPageScaffold> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAppBarScaffold(
      scrollController: _scrollController,
      title: widget.title,
      previousPageTitle: widget.previousPageTitle,
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        children: widget.children
      ),
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final headerStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(kHeaderFooterColor, context),
    );

    return SettingsPageScaffold(
      title: "Settings",
      previousPageTitle: "Home",
      children: [
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text("THEME", style: headerStyle),
          ),
          children: [
            SelectionSettingWidget(
              name: "UI Theme",
              pageTitle: "Settings",
              options: UITheme.values,
              selectedOption: settings.uiTheme,
              onSelection: (option) {
                ref.read(settingsProvider.notifier).update(settings.copyWith(
                  uiTheme: option,
                ));
              },
            ),
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
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text("MAP", style: headerStyle),
          ),
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
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text("ADVANCED", style: headerStyle),
          ),
          children: [
            ButtonSettingWidget(
              name: "Reset database",
              buttonStyle: ButtonSettingStyle.danger,
              confirmation: SettingConfirmation(
                title: "Reset database?",
                content: "All settings and offline reports will be lost."),
              onTap: () {
                ref.read(forestParkDatabaseProvider.notifier).delete();
              },
            )
          ],
        ),
      ],
    );
  }
}

class ToggleSettingWidget extends StatelessWidget {
  final String name;
  final bool value;
  final void Function(bool toggled) onChanged;
  const ToggleSettingWidget({
    super.key,
    required this.name,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      title: Text(name),
      trailing: PlatformSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}


class SettingConfirmation {
  final String title;
  final String content;
  SettingConfirmation({required this.title, required this.content});
}

enum ButtonSettingStyle {
  none,
  danger,
  button,
}

class ButtonSettingWidget extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final ButtonSettingStyle buttonStyle;
  final SettingConfirmation? confirmation;

  const ButtonSettingWidget({
    super.key,
    required this.name,
    required this.onTap,
    this.buttonStyle = ButtonSettingStyle.button,
    this.confirmation,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = switch(buttonStyle) {
      ButtonSettingStyle.none => null,
      ButtonSettingStyle.danger => CupertinoTheme.of(context).textTheme.actionTextStyle.copyWith(
        color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
      ),
      ButtonSettingStyle.button => CupertinoTheme.of(context).textTheme.actionTextStyle,
    };

    return PlatformListTile(
      title: Text(
        name,
        style: textStyle
      ),
      onTap: () async {
        final delay = Future.delayed(const Duration(milliseconds: 100));
        if (confirmation == null) {
          onTap();
        } else {
          final confirmed = await showPlatformDialog(
            context: context,
            builder: (context) => PlatformAlertDialog(
              title: Text(confirmation!.title),
              content: Text(confirmation!.content),
              actions: [
                PlatformDialogAction(
                  child: PlatformText("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                PlatformDialogAction(
                  child: PlatformText("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ]
            )
          );
          if (confirmed) {
            onTap();
          }
        }
        await delay;
      },
    );
  }
}

class SelectionSettingWidget<T extends SelectionOption> extends StatelessWidget {
  final String name;
  final Iterable<T> options;
  final T selectedOption;
  final void Function(T option) onSelection;
  final String? pageTitle;
  const SelectionSettingWidget({super.key, required this.name, required this.options, required this.selectedOption, required this.onSelection, this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      title: Text(name),
      trailing: const CupertinoListTileChevron(),
      cupertino: (_, __) => CupertinoListTileData(
        additionalInfo: Text(selectedOption.displayName),
      ),
      onTap: () async {
        await Navigator.of(context).push(
          platformPageRoute(
            context: context,
            builder: (context) => _SelectionSettingWidgetPage(
              name: name,
              pageTitle: pageTitle,
              options: options,
              onSelection: (option) {
                onSelection(option as T);
              },
              selectedOption: selectedOption,
            ),
          ),
        );
      },
    );
  }
}

class _SelectionSettingWidgetPage extends StatefulWidget {
  const _SelectionSettingWidgetPage({
    super.key,
    required this.name,
    required this.pageTitle,
    required this.options,
    required this.onSelection,
    required this.selectedOption,
  });

  final String name;
  final String? pageTitle;
  final Iterable<SelectionOption> options;
  final void Function(SelectionOption option) onSelection;
  final SelectionOption selectedOption;

  @override
  State<_SelectionSettingWidgetPage> createState() => _SelectionSettingWidgetPageState();
}

class _SelectionSettingWidgetPageState extends State<_SelectionSettingWidgetPage> {
  late SelectionOption selected = widget.selectedOption;

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: widget.name,
      previousPageTitle: widget.pageTitle,
      children: [
        CupertinoListSection.insetGrouped(
          children: [
            for (final option in widget.options)
              PlatformListTile(
                title: Text(option.displayName),
                onTap: () async {
                  final delay = Future.delayed(const Duration(milliseconds: 100));
                  widget.onSelection.call(option);
                  setState(() {
                    selected = option;
                  });
                  await delay;
                },
                trailing: option == selected ? Icon(
                  CupertinoIcons.checkmark,
                  size: CupertinoTheme.of(context).textTheme.textStyle.fontSize,
                ) : null,
              ),
          ],
        ),
      ]
    );
  }
}

const kHeaderFooterColor = CupertinoDynamicColor(
  color: Color.fromRGBO(108, 108, 108, 1.0),
  darkColor: Color.fromRGBO(142, 142, 146, 1.0),
  highContrastColor: Color.fromRGBO(74, 74, 77, 1.0),
  darkHighContrastColor: Color.fromRGBO(176, 176, 183, 1.0),
  elevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
  darkElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
  highContrastElevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
  darkHighContrastElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
);
