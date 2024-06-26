import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
