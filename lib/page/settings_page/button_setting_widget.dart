import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forest_park_reports/page/common/confirmation.dart';

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
  final ConfirmationInfo? confirmation;

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
      ButtonSettingStyle.danger => TextStyle(
        color: Theme.of(context).colorScheme.error,
      ),
      ButtonSettingStyle.button => null,
    };

    return ListTile(
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
          final bool confirmed = await showConfirmationDialog(context, confirmation!);
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
