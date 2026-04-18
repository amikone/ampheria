// lib/widgets/gender_selector.dart

import 'package:flutter/material.dart';
import '../../Services/GenderService.dart';

class GenderSelector extends StatefulWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  List<String> _genders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final genders = await GenderService.fetchGenders();
    if (mounted) {
      setState(() {
        _genders = genders;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: Colors.deepPurpleAccent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _genders.map((gender) {
        final isSelected = widget.selectedGender == gender;
        return GestureDetector(
          onTap: () => widget.onChanged(gender),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
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
              gender,
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