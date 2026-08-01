import 'package:flutter/material.dart';
import 'package:ampheria/services/gender_service.dart';

class InterestedInSelector extends StatefulWidget {
  final List<String> selectedGenders;
  final ValueChanged<List<String>> onChanged;

  const InterestedInSelector({
    super.key,
    required this.selectedGenders,
    required this.onChanged,
  });

  @override
  State<InterestedInSelector> createState() => _InterestedInSelectorState();
}

class _InterestedInSelectorState extends State<InterestedInSelector> {
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
        child: CircularProgressIndicator(
          color: Colors.deepPurpleAccent,
          strokeWidth: 2,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _genders.map((gender) {
        final isSelected = widget.selectedGenders.contains(gender);
        return FilterChip(
          label: Text(
            gender,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedColor: Colors.deepPurpleAccent.withOpacity(0.3),
          checkmarkColor: Colors.deepPurpleAccent,
          backgroundColor: Colors.white.withOpacity(0.05),
          side: BorderSide(
            color: isSelected ? Colors.deepPurpleAccent : Colors.white.withOpacity(0.2),
          ),
          onSelected: (selected) {
            final newList = List<String>.from(widget.selectedGenders);
            if (selected) {
              newList.add(gender);
            } else {
              newList.remove(gender);
            }
            widget.onChanged(newList);
          },
        );
      }).toList(),
    );
  }
}
