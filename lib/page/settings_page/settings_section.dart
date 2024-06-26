import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/page/settings_page/settings_page_scaffold.dart';

/// A Settings group using [CupertinoListSection.insetGrouped()] on iOS and Material style dividers on Android.
class SettingsSection extends PlatformWidgetBase {
  /// The children; these should be settings tiles (but are not required to be).
  final List<Widget> children;
  /// The label/heading displayed at the beginning of the group. Rendered in caps on iOS.
  final String? label;
  const SettingsSection({super.key, required this.children, this.label});

  @override
  Widget createCupertinoWidget(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: CupertinoDynamicColor.resolve(CupertinoColors.systemGroupedBackground, context),
      header: label != null
          ? Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          label!.toUpperCase(),
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontSize: 14,
            color: CupertinoDynamicColor.resolve(kHeaderFooterColor, context),
          ),
        ),
      ) : null,
      children: children,
    );
  }

  @override
  Widget createMaterialWidget(BuildContext context) {
    return Column(
      children: [
        if (label != null)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: kAndroidSettingsMargin, top: 10, bottom: 10),
              child: Text(
                  label!,
                  style: Theme.of(context).textTheme.labelMedium
              ),
            ),
          ),
        const Divider(
          height: 0,
          indent: kAndroidSettingsMargin,
          endIndent: kAndroidSettingsMargin,
        ),
        for (final child in children)
          ...[
            child,
            const Divider(
              height: 0,
              indent: kAndroidSettingsMargin,
              endIndent: kAndroidSettingsMargin,
            ),
          ],
        const Padding(padding: EdgeInsets.only(bottom: 20))
      ],
    );
  }
}
