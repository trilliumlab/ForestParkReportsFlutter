import 'dart:ui';

import 'package:flutter/widgets.dart';

const kBlurSteps = 6;
const double kMaxSigma = 4;
const double kOverlap = 4;

/// Blurs the top status bar (used for iOS devices)
class StatusBarBlur extends StatelessWidget {
  const StatusBarBlur({super.key});
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).viewPadding.top;
    final stepHeight = height/kBlurSteps;

    return Align(
      alignment: Alignment.topCenter,
      child: Stack(
        children: [
          for (int i = 0; i < kBlurSteps; ++i) () {
            final sigma = (1-(i.toDouble()/kBlurSteps))*kMaxSigma;
            return Positioned(
              top: i * stepHeight,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: Container(height: stepHeight + kOverlap),
                ),
              ),
            );
          }()
        ],
      )
    );
  }
}
