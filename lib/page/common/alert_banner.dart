import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/main.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';

const double kAlertBannerHeight = 40;
const double kCupertinoAlertCornerRadius = 14.0;
const kAlertAnimationDuration = Duration(milliseconds: 750);
const kAlertUpdateDuration = Duration(milliseconds: 200);

final Map<Key, Widget Function(BuildContext)> _alertChildren = {};
final Map<Key, OverlayEntry> _alertEntries = {};

void showAlertBanner({
  required Widget child,
  required Color color,
  Key? key,
  Duration duration = const Duration(seconds: 3),
}) {
  if (homeKey.currentContext == null) {
    return;
  }
  final overlayKey = key ?? UniqueKey();

  final shouldInsert = !_alertChildren.containsKey(overlayKey);
  _alertChildren[overlayKey] = (context) => _AlertBanner(
    key: overlayKey,
    waitDuration: duration,
    onDismissed: () {
      _alertEntries.remove(overlayKey)?.remove();
      _alertChildren.remove(overlayKey);
    },
    child: _AlertBannerContent(
      color: color,
      child: child,
    ),
  );

  if (shouldInsert) {
    _alertEntries[overlayKey] = OverlayEntry(
        builder: (context) => _alertChildren[overlayKey]!(context)
    );
    Overlay.of(homeKey.currentContext!).insert(_alertEntries[overlayKey]!);
  } else {
    _alertEntries[overlayKey]?.markNeedsBuild();
  }
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
  int _alertUpdates = 0;
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

  @override
  void didUpdateWidget(covariant _AlertBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the alert is updated we should reset the timer
    _maybeCancelClose();
  }

  Future<void> _maybeCancelClose() async {
    ++_alertUpdates;
    // velocity < 0 means notification is closing, we should reverse animation
    if (_controller.velocity < 0) {
      // Smoothly animate turn around
      await _controller.animateWith(FrictionSimulation(0.1, _controller.value, _controller.velocity, constantDeceleration: 1));
      await _controller.forward();
    }
    _waitClose();
  }

  Future<void> _animate() async {
    await _controller.forward();
    _waitClose();
  }

  Future<void> _waitClose() async {
    int updates = _alertUpdates;
    await Future.delayed(widget.waitDuration);
    // If no new updates then this timer is valid
    if (updates == _alertUpdates && mounted && !_dismissed) {
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

  static final offset1 = Tween(begin: const Offset(1, 0), end: const Offset(0, 0));
  static final offset2 = Tween(begin: const Offset(-1, 0), end: const Offset(0, 0));

  const _AlertBannerContent({
    required this.color,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedSwitcher(
          duration: kAlertUpdateDuration,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) => (animation.value != 1 ? SizeTransition(
            axis: Axis.vertical,
            sizeFactor: animation,
            child: child,
          ) : child),
          child: Container(
            key: Key(color.toString()),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                color: color
            ),
            height: kAlertBannerHeight,
            width: 5,
          ),
        ),
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: kAlertUpdateDuration,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) => SlideTransition(
                position: (animation.value == 1? offset1 : offset2).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
