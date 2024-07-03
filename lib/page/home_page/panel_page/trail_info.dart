import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forest_park_reports/util/panel_values.dart';
import 'package:forest_park_reports/page/common/platform_pill.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

/// The main body of the panel when a trail is selected on the map
class TrailInfoWidget extends StatefulWidget {
  final ScrollController scrollController;
  final PanelController panelController;
  final List<Widget> children;
  final String? title;
  final Widget? bottomWidget;
  const TrailInfoWidget({
    super.key,
    required this.scrollController,
    required this.panelController,
    required this.children,
    this.bottomWidget,
    this.title,
  });

  @override
  State<TrailInfoWidget> createState() => _TrailInfoWidgetState();
}

class _TrailInfoWidgetState extends State<TrailInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: max(PanelValues.snapHeight(context), widget.panelController.panelHeight)
            - MediaQueryData.fromView(View.of(context)).padding.bottom,
        child: Column(
          children: [
            Stack(
              children: [
                if (widget.title != null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 14, top: 16, bottom: 10),
                      child: Text(
                        widget.title!,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                const Align(
                  alignment: Alignment.topCenter,
                  child: PlatformPill(),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: CustomScrollView(
                    controller: widget.scrollController,
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          ...widget.children,
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.bottomWidget != null)
              ClipRect(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: widget.bottomWidget!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    //TODO check this out
        // if (widget.title != null)
        //   Align(
        //     alignment: Alignment.topLeft,
        //     child: ClipRect(
        //       child: BackdropFilter(
        //         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        //         child: Container(
        //           color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
        //           width: MediaQuery.of(context).size.width,
        //           child: Padding(
        //             key: _textKey,
        //             padding: const EdgeInsets.only(left: 14, right: 14, top: 16, bottom: 6),
        //             child: Text(
        //               widget.title!,
        //               style: theme.textTheme.headline6,
        //               maxLines: 2,
        //               overflow: TextOverflow.ellipsis,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // if (widget.bottomWidget != null)
        //   Positioned(
        //     bottom: (
        //         widget.panelController.panelOpenHeight-
        //             max(
        //                 widget.panelController.panelHeight,
        //                 widget.panelController.panelSnapHeight
        //             )
        //     ),
        //     child: ClipRect(
        //       child: BackdropFilter(
        //         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        //         child: Container(
        //           color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
        //           child: Padding(
        //             padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 4),
        //             child: SizedBox(
        //               width: width,
        //               child: widget.bottomWidget!,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
  }
}
