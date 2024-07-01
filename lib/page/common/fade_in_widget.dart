import 'package:flutter/widgets.dart';

/// A widget that fades in it's children.
/// Commonly used to show a placeholder widget while a widget is loading.
///
/// [placeholder] and [child] are rendered in a stack with [child] on top of [placeholder].
/// If [child] is initially non-null, [placeholder] will never be rendered.
class FadeInWidget extends StatefulWidget {
  /// The widget rendered when [child] is null.
  final Widget? placeholder;
  /// The child widget.
  final Widget? child;
  /// The duration of the placeholder fade-in animation.
  final Duration placeholderFadeDuration;
  /// The duration of the child fade-in animation.
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
        // Fade out placeholder
        _placeholderController.reverse();
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
