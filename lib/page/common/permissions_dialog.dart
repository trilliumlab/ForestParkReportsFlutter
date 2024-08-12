import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// UI to request location
showMissingPermissionDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text("Go To Settings"),
          onPressed: () {
            Geolocator.openAppSettings();
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}
