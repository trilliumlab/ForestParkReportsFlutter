import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Holds information for showing a confirmation dialog.
class ConfirmationInfo {
  /// The confirmation title.
  final String title;
  /// The confirmation content.
  final String content;
  /// The text to show on the negative/cancel button.
  final String negative;
  /// The text to show on the affirmative/confirm button.
  final String affirmative;

  ConfirmationInfo({
    required this.title,
    required this.content,
    this.negative = "Cancel",
    this.affirmative = "Ok",
  });
}

Future<bool> showConfirmationDialog(BuildContext context, ConfirmationInfo confirmation) async {
  return await showPlatformDialog(
    context: context,
    builder: (context) => PlatformAlertDialog(
      title: Text(confirmation.title),
      content: Text(confirmation.content),
      actions: [
        PlatformDialogAction(
          child: PlatformText(confirmation.negative),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        PlatformDialogAction(
          child: PlatformText(confirmation.affirmative),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    ),
  );
}
