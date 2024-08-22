import 'package:flutter/material.dart';

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
    return ListTile(
      title: Text(name),
      onTap: () {
        onChanged(!value);
      },
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
