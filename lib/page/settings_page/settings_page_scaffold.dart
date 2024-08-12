import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:forest_park_reports/page/settings_page/settings_section.dart';

/// A Scaffold for settings designed to render [SettingsSection].
class SettingsPageScaffold extends StatefulWidget {
  /// The children to render; these should be [SettingsSection] (but are not required to be).
  final List<Widget> children;
  /// The page title
  final String title;
  /// The previous page title
  ///
  /// Used on iOS to display next to the back button.
  final String? previousPageTitle;
  const SettingsPageScaffold({super.key, required this.children, required this.title, this.previousPageTitle});

  @override
  State<SettingsPageScaffold> createState() => _SettingsPageScaffoldState();
}

class _SettingsPageScaffoldState extends State<SettingsPageScaffold> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          // Allows bouncing even when content doesn't fill up the screen
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          children: widget.children
        ),
    );
  }
}

/// The margin from the side of the screen for settings tiles on Android.
const double kAndroidSettingsMargin = 16;
const kHeaderFooterColor = CupertinoDynamicColor(
  color: Color.fromRGBO(108, 108, 108, 1.0),
  darkColor: Color.fromRGBO(142, 142, 146, 1.0),
  highContrastColor: Color.fromRGBO(74, 74, 77, 1.0),
  darkHighContrastColor: Color.fromRGBO(176, 176, 183, 1.0),
  elevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
  darkElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
  highContrastElevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
  darkHighContrastElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
);
