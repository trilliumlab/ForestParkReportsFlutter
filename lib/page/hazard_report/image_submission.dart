import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSubmission extends StatefulWidget {
  const ImageSubmission({super.key, required this.onImageSubmitted});

  final void Function(XFile onImageSubmitted) onImageSubmitted;
  @override
  State<ImageSubmission> createState() => _ImageSubmissionState();
}

class _ImageSubmissionState extends State<ImageSubmission> {
  final _picker = ImagePicker();
  XFile? _image;

  Future _cameraSelect() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
        widget.onImageSubmitted(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: FilledButton(
          style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainer),
              padding: const WidgetStatePropertyAll(EdgeInsets.only())
          ),
          onPressed: null,
          child: InkWell(
              onTap: _cameraSelect,
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: _image == null ? Icon(
                    Icons.camera_alt_rounded,
                    color: theme.colorScheme.primary,
                ) : Image.file(
                  File(_image!.path),
                  fit: BoxFit.cover,
                ),
              ),
          ),
      ),
    );
  }
}

Future<bool> showNoImageAlert(BuildContext context,
  {bool overrideEnabled = true}) async {
  return await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('No photo submitted'),
      content: overrideEnabled
        ? const Text('Are you sure you\'d like to submit this report without a photo?')
        : const Text('Your report must include a photo'),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        if (overrideEnabled) TextButton(
          child: const Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    )
  ) ?? false;
}