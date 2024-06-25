import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Blurs the top status bar (used for iOS devices)
class StatusBarBlur extends StatelessWidget {
  const StatusBarBlur({super.key});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: MediaQuery.of(context).viewPadding.top,
          ),
        ),
      ),
    );
  }
}
