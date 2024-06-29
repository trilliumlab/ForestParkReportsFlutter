import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/provider/hazard_photo_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Displays an image of a hazard; used in hazard_info, trail_info, and panel_page
class HazardImage extends ConsumerWidget {
  final String uuid;
  final String? blurHash;
  const HazardImage(this.uuid, {super.key, this.blurHash});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(hazardPhotoProvider(uuid));

    final prov = BlurhashFfiImage(blurHash!);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (blurHash != null)
          FadeInWidget(
            placeholder: Image(
              image: prov,
              fit: BoxFit.cover,
            ),
            child: image.hasValue ? Image(
              image: image.value!,
              fit: BoxFit.cover,
            ) : null,
          )
        else if (image.hasValue)
          FadeInWidget(
            child: Image(
              image: image.value!,
              fit: BoxFit.cover,
            ),
          )
        else
          Center(
            child: PlatformCircularProgressIndicator(),
          ),
      ],
    );
  }
}

class FadeInWidget extends StatefulWidget {
  final Widget? placeholder;
  final Widget? child;
  final Duration placeholderFadeDuration;
  final Duration childFadeDuration;
  const FadeInWidget({
    this.placeholder,
    this.child,
    this.placeholderFadeDuration = const Duration(milliseconds: 100),
    this.childFadeDuration = const Duration(milliseconds: 100),
    super.key
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with TickerProviderStateMixin {
  late final AnimationController _placeholderController;
  late final AnimationController _childController;
  var _renderPlaceholder = true;

  @override
  void initState() {
    super.initState();

    _placeholderController = AnimationController(
      duration: widget.placeholderFadeDuration,
      vsync: this,
    );
    _childController = AnimationController(
      duration: widget.childFadeDuration,
      vsync: this,
    );

    if (widget.placeholder != null) {
      _placeholderController.forward();
    }
    if (widget.child != null) {
      _childController.forward();
      _renderPlaceholder = false;
    }
  }

  @override
  void didUpdateWidget(covariant FadeInWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) {
      if (oldWidget.child == null) {
        // The child just became non-null so we should fade in
        _childController.forward();
      }
    }
    if (widget.placeholder != oldWidget.placeholder) {
      if (oldWidget.placeholder == null) {
        // The child just became non-null so we should fade in
        _placeholderController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: AlignmentDirectional.center,
      textDirection: TextDirection.ltr,
      children: [
        if (_renderPlaceholder)
          FadeTransition(
            opacity: _placeholderController,
            child: widget.placeholder,
          ),
        FadeTransition(
          opacity: _childController,
          child: widget.child,
        ),
      ],
    );
  }
}
