import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/main.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';

const double kAlertBannerHeight = 40;
const double kCupertinoAlertCornerRadius = 14.0;
const kAlertAnimationDuration = Duration(milliseconds: 750);

void showAlertBanner({
  required Widget child,
  required Color color,
  Duration duration = const Duration(seconds: 3),
}) {
  if (homeKey.currentContext == null) {
    return;
  }
  final key = UniqueKey();
  late final OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => _AlertBanner(
      key: key,
      waitDuration: duration,
      onDismissed: () {
        overlayEntry.remove();
      },
      child: _AlertBannerContent(
        color: color,
        child: child,
      ),
    ),
  );
  Overlay.of(homeKey.currentContext!).insert(overlayEntry);
}

class _AlertBanner extends StatefulWidget {
  final Duration waitDuration;
  final VoidCallback onDismissed;
  final Widget child;

  const _AlertBanner({
    required this.waitDuration,
    required this.onDismissed,
    required this.child,
    required super.key,
  });

  @override
  State<_AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<_AlertBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this,
    duration: kAlertAnimationDuration,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, -2.5),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  ));

  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _animate();
  }

  Future<void> _animate() async {
    await _controller.forward();
    await Future.delayed(widget.waitDuration);
    if (mounted && !_dismissed) {
      await _controller.reverse();
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top;
    return Positioned(
      left: kFabPadding,
      right: kFabPadding,
      child: Dismissible(
        key: widget.key!,
        direction: DismissDirection.up,
        onDismissed: (_) {
          _dismissed = false;
          widget.onDismissed();
        },
        child: Padding(
          padding: EdgeInsets.only(top: topPadding + kFabPadding),
          child: SlideTransition(
            position: _offsetAnimation,
            child: _AlertBannerBackground(
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertBannerBackground extends PlatformWidgetBase {
  final Widget child;

  const _AlertBannerBackground({
    required this.child,
    super.key
  });

  @override
  Widget createCupertinoWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kCupertinoAlertCornerRadius),
        boxShadow: [
          OutlineBoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: CupertinoPopupSurface(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kFabPadding,
            vertical: kFabPadding,
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget createMaterialWidget(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kFabPadding,
          vertical: kFabPadding,
        ),
        child: child,
      ),
    );
  }
}

class _AlertBannerContent extends StatelessWidget {
  final Color color;
  final Widget child;

  const _AlertBannerContent({
    required this.color,
    required this.child,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
            color: color
          ),
          height: kAlertBannerHeight,
          width: 5,
        ),
        Expanded(
          child: Center(
            child: child,
          ),
        ),
      ],
    );
  }
}
