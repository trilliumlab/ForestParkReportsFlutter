import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// An animated platform app bar that changes color when scrolled.
///
/// Renders a [CupertinoNavigationBar] on iOS and a [AppBar] on Android.
class AnimatedAppBarScaffold extends StatefulWidget {
  /// The child [Widget].
  final Widget body;
  /// Scroll controller of body scrollview.
  ///
  /// Used to know when to change color.
  final ScrollController scrollController;
  /// App bar title.
  final String title;
  /// Previous page title; shown next to back button on iOS.
  final String? previousPageTitle;
  const AnimatedAppBarScaffold({super.key, required this.body, required this.scrollController, required this.title, this.previousPageTitle});

  @override
  State<AnimatedAppBarScaffold> createState() => _AnimatedAppBarScaffoldState();
}

class _AnimatedAppBarScaffoldState extends State<AnimatedAppBarScaffold> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  Animation<Color?>? _barColorTween;
  Animation<Color?>? _separatorColorTween;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: Duration.zero);
    // Called whenever we scroll.
    widget.scrollController.addListener(scrollListener);
  }

  Color get _background => isCupertino(context)
        ? CupertinoDynamicColor.resolve(CupertinoColors.systemGroupedBackground, context)
        : Theme.of(context).scaffoldBackgroundColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final barColor = isCupertino(context)
        ? CupertinoTheme.of(context).barBackgroundColor.withAlpha(150)
        : Theme.of(context).colorScheme.surface;

    _barColorTween = ColorTween(
        begin: _background,
        end: barColor,
    ).animate(_animationController);
    _separatorColorTween = ColorTween(
      begin: _background,
      end: CupertinoDynamicColor.resolve(CupertinoColors.separator, context).withAlpha(150),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollListener);

    super.dispose();
  }

  void scrollListener() {
    // We want to progress the animation smoothly as we transition to scrolling
    // Therefore the first 12 pixels are the transition zone.
    // How far we are down in these pixels should be how much we animate.
    double a = (widget.scrollController.offset/kScrollTransition).clamp(0, 1);
    _animationController.animateTo(a);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = isCupertino(context)
        ? CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 20)
        : null;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => PlatformScaffold(
          appBar: PlatformAppBar(
            title: Text(widget.title, style: titleStyle),
            backgroundColor: _barColorTween!.value,
            cupertino: (context, _) => CupertinoNavigationBarData(
              previousPageTitle: widget.previousPageTitle,
              border: Border(
                bottom: BorderSide(
                  color: _separatorColorTween!.value ?? _background,
                  width: 0.0, // 0.0 means one physical pixel
                ),
              ),
            ),
          ),
          backgroundColor: _background,
          body: child
      ),
      child: widget.body,
    );
  }
}

/// How many pixels the app bar animation is done over.
const double kScrollTransition = 12;
