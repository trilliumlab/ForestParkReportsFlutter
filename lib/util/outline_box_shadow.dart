import 'package:flutter/cupertino.dart';

class OutlineBoxShadow extends BoxShadow {
  const OutlineBoxShadow({
    super.color,
    super.offset,
    super.blurRadius,
  });

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, blurSigma);
    assert(() {
      if (debugDisableShadows) {
        result.maskFilter = null;
      }
      return true;
    }());
    return result;
  }
}