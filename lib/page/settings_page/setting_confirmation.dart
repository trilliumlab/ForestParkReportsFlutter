import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Holds information for showing a confirmation dialog.
class SettingConfirmation {
  /// The confirmation title.
  final String title;
  /// The confirmation content.
  final String content;
  

  SettingConfirmation({required this.title, required this.content});
}

Future<bool> showConfirmationDialog(BuildContext context, SettingConfirmation confirmation) async {
  return await showPlatformDialog(
    context: context,
    builder: (context) => PlatformAlertDialog(
      title: Text(confirmation.title),
      content: Text(confirmation.content),
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
}
