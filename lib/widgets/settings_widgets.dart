import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/models/settings.dart';
import 'package:forest_park_reports/widgets/animated_app_bar_scaffold.dart';

/// A Scaffold for settings designed to render [SettingsSection].
class SettingsPageScaffold extends StatefulWidget {
  /// The children to render; these should be [SettingsSection] (but are not required to be).
  final List<Widget> children;
  /// The page title
  final String title;
  /// The previous page title
  ///
  /// Used on iOS to display next to the back button.
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
      // Pass the scroll controller to AnimatedAppBarScaffold so it knows when to show and hide.
      scrollController: _scrollController,
      title: widget.title,
      previousPageTitle: widget.previousPageTitle,
      body: ListView(
        // Allows bouncing even when content doesn't fill up the screen
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        children: widget.children
      ),
    );
  }
}

/// A Settings group using [CupertinoListSection.insetGrouped()] on iOS and Material style dividers on Android.
class SettingsSection extends PlatformWidgetBase {
  /// The children; these should be settings tiles (but are not required to be).
  final List<Widget> children;
  /// The label/heading displayed at the beginning of the group. Rendered in caps on iOS.
  final String? label;
  const SettingsSection({super.key, required this.children, this.label});

  @override
  Widget createCupertinoWidget(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: CupertinoDynamicColor.resolve(CupertinoColors.systemGroupedBackground, context),
      header: label != null
          ? Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          label!.toUpperCase(),
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontSize: 14,
            color: CupertinoDynamicColor.resolve(kHeaderFooterColor, context),
          ),
        ),
      ) : null,
      children: children,
    );
  }

  @override
  Widget createMaterialWidget(BuildContext context) {
    return Column(
      children: [
        if (label != null)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: kAndroidSettingsMargin, top: 10, bottom: 10),
              child: Text(
                  label!,
                  style: Theme.of(context).textTheme.labelMedium
              ),
            ),
          ),
        const Divider(
          height: 0,
          indent: kAndroidSettingsMargin,
          endIndent: kAndroidSettingsMargin,
        ),
        for (final child in children)
          ...[
            child,
            const Divider(
              height: 0,
              indent: kAndroidSettingsMargin,
              endIndent: kAndroidSettingsMargin,
            ),
          ],
        const Padding(padding: EdgeInsets.only(bottom: 20))
      ],
    );
  }
}

/// A settings widget for boolean options.
class ToggleSettingWidget extends StatelessWidget {
  /// The setting name.
  final String name;
  /// The current value.
  final bool value;
  /// Called whenever the switch is toggled. [value] will need to be updated to render.
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
      material: (_, __) => MaterialListTileData(
        // Allow clicking the entire tile on Android.
        onTap: () {
          onChanged(!value);
        }
      ),
      title: Text(name),
      trailing: PlatformSwitch(
        material: (_, __) => MaterialSwitchData(
          thumbIcon: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? const Icon(Icons.check)
                : const Icon(Icons.close);
          },
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// Holds information for showing a confirmation dialog.
class SettingConfirmation {
  /// The confirmation title.
  final String title;
  /// The confirmation content.
  final String content;
  SettingConfirmation({required this.title, required this.content});
}

/// Styles for [ButtonSettingWidget].
enum ButtonSettingStyle {
  /// Default text style.
  none,
  /// Red text indicating a dangerous (irreversible) action.
  danger,
  /// Primary color text indication a link/action (blue on iOS).
  button,
}

/// A settings widget for actions.
class ButtonSettingWidget extends StatelessWidget {
  /// The setting name.
  final String name;
  /// Called when the tile is pressed.
  ///
  /// If [confirmation] is non null, it will be called only after the action has been confirmed.
  final VoidCallback onTap;
  /// The style; used to denote what type of action is being preformed. See [ButtonSettingStyle].
  final ButtonSettingStyle buttonStyle;
  /// The confirmation info. If null, no confirmation is presented.
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
          // Wait for confirmation before calling onTap.
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
                ),
              ],
            ),
          );
          if (confirmed) {
            onTap();
          }
        }
        // Keep future alive for at least 100ms since this triggers highlighting the button.
        await delay;
      },
    );
  }
}

/// A setting for a selection options. Opens selections in a new page.
class SelectionSettingWidget<T extends SelectionOption> extends StatelessWidget {
  /// The setting name.
  final String name;
  /// The [SelectionOption] to be rendered.
  final Iterable<T> options;
  /// The selected option.
  final T selectedOption;
  /// Called when a new option is selected. Note: state is handled internally
  /// but [selectedOption] should still be updated in this function.
  final void Function(T option) onSelection;
  /// The current page title. This is used on iOS next to the back button on the created page.
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

/// A page with selections created by [SelectionSettingWidget]. Holds selection state internally.
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
          SettingsSection(
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

/// The margin from the side of the screen for settings tiles on Android.
const double kAndroidSettingsMargin = 16;
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
