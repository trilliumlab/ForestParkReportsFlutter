import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AnimatedAppBarScaffold extends StatefulWidget {
  final Widget body;
  final ScrollController scrollController;
  final String title;
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
    widget.scrollController.addListener(scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final background = CupertinoDynamicColor.resolve(CupertinoColors.systemGroupedBackground, context);
    _barColorTween = ColorTween(
        begin: background,
        end: CupertinoTheme.of(context).barBackgroundColor.withAlpha(150)
    ).animate(_animationController);
    _separatorColorTween = ColorTween(
      begin: background,
      end: CupertinoDynamicColor.resolve(CupertinoColors.separator, context).withAlpha(150),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollListener);

    super.dispose();
  }

  void scrollListener() {
    double a = (widget.scrollController.offset/12).clamp(0, 1);
    _animationController.animateTo(a);
  }

  @override
  Widget build(BuildContext context) {
    final background = CupertinoDynamicColor.resolve(CupertinoColors.systemGroupedBackground, context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => PlatformScaffold(
          appBar: PlatformAppBar(
            title: Text(widget.title, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 20)),
            cupertino: (context, _) => CupertinoNavigationBarData(
              backgroundColor: _barColorTween!.value,
              previousPageTitle: widget.previousPageTitle,
              border: Border(
                bottom: BorderSide(
                  color: _separatorColorTween!.value ?? background,
                  width: 0.0, // 0.0 means one physical pixel
                ),
              ),
            ),
          ),
          backgroundColor: background,
          body: child
      ),
      child: widget.body,
    );
  }
}