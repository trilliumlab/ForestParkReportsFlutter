import 'package:flutter/material.dart';
import 'package:forest_park_reports/model/settings.dart';
import 'package:forest_park_reports/page/settings_page/settings_page_scaffold.dart';

import 'settings_section.dart';

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
    return ListTile(
      title: Text(name),
      // TODO: material alternative - trailing: const CupertinoListTileChevron(),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
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
                ListTile(
                  title: Text(option.displayName),
                  onTap: () async {
                    final delay = Future.delayed(const Duration(milliseconds: 100));
                    widget.onSelection.call(option);
                    setState(() {
                      selected = option;
                    });
                    await delay;
                  },
                  trailing: option == selected ? const Icon(
                    Icons.check_rounded,
                  ) : null,
                ),
            ],
          ),
        ]
    );
  }
}
