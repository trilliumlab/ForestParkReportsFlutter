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
