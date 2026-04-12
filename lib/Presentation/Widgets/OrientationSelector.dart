// lib/widgets/orientation_selector.dart

import 'package:flutter/material.dart';
import '../../Services/ReferenceDataService.dart';

class OrientationSelector extends StatefulWidget {
  final String? selectedOrientation;
  final ValueChanged<String?> onChanged;

  const OrientationSelector({
    super.key,
    required this.selectedOrientation,
    required this.onChanged,
  });

  @override
  State<OrientationSelector> createState() => _OrientationSelectorState();
}

class _OrientationSelectorState extends State<OrientationSelector> {
  List<String> _orientations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ReferenceDataService.fetchOrientations();
    if (mounted) {
      setState(() {
        _orientations = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurpleAccent,
          strokeWidth: 2,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _orientations.map((orientation) {
        final isSelected = widget.selectedOrientation == orientation;
        return GestureDetector(
          onTap: () => widget.onChanged(orientation),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.deepPurpleAccent.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? Colors.deepPurpleAccent
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              orientation,
              style: TextStyle(
                color: isSelected
                    ? Colors.deepPurpleAccent
                    : Colors.white70,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}