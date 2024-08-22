

import 'package:flutter/material.dart';

class SegmentOptions<T> extends StatefulWidget {
  const SegmentOptions({super.key, required this.onSelectionChanged, required this.options, this.initialOption});
  
  final Map<T, Widget> options;
  final T? initialOption;
  
  final void Function(T) onSelectionChanged;
  @override
  State<SegmentOptions> createState() => _SegmentOptionsState<T>();
}

class _SegmentOptionsState<T> extends State<SegmentOptions> {
  T? _selectedOption;
  
  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      emptySelectionAllowed: widget.initialOption == null,
      showSelectedIcon: false,
      selected: {
        if (_selectedOption != null)
          _selectedOption!
      },
      onSelectionChanged: (selection) {
        if (selection.length == 1) {
          setState(() {
            _selectedOption = selection.first;

          });
        }
      },
      segments: [
        for (final option in widget.options.entries)
          ButtonSegment(
            value: option.key,
            label: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: option.value
            ),
          ),
      ],
    );
  }
}