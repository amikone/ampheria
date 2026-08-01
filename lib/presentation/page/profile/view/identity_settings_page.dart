import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ampheria/extensions/context_extension.dart';
import 'package:ampheria/services/reference_data_service.dart';
import 'package:ampheria/presentation/widgets/gender_selector.dart';
import 'package:ampheria/presentation/widgets/orientation_selector.dart';
import 'package:ampheria/presentation/widgets/interested_in_selector.dart';

class IdentitySettingsPage extends StatefulWidget {
  final String? initialGender;
  final String? initialOrientation;
  final List<String> initialInterestedIn;

  const IdentitySettingsPage({
    super.key,
    this.initialGender,
    this.initialOrientation,
    required this.initialInterestedIn,
  });

  @override
  State<IdentitySettingsPage> createState() => _IdentitySettingsPageState();
}

class _IdentitySettingsPageState extends State<IdentitySettingsPage> {
  final supabase = Supabase.instance.client;
  Timer? _debounce;

  late String? _myGender;
  late String? _myOrientation;
  late List<String> _interestedIn;

  @override
  void initState() {
    super.initState();
    _myGender = widget.initialGender;
    _myOrientation = widget.initialOrientation;
    _interestedIn = List<String>.from(widget.initialInterestedIn);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _saveData() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      try {
        // Save Gender and Orientation in profiles
        await supabase.from('profiles').update({
          'gender': _myGender,
          'orientation': _myOrientation,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);

        // Save Preferences
        await supabase.from('user_preferences').upsert({
          'user_id': user.id,
          'interested_in': _interestedIn,
        });
      } catch (e) {
        print("Error saving identity: $e");
      }
    });
  }

  void _showSuggestionBanner(List<String> suggested) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF1E1B2E),
        content: Text(
          '${context.localizations.applySuggestionPrompt} ${suggested.join(', ')} ?',
          style: const TextStyle(color: Colors.white70),
        ),
        leading: const Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text(context.localizations.ignore, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _interestedIn = suggested;
              });
              _saveData();
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: Text(
              context.localizations.apply,
              style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String subtitle, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 16),
        child,
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(context.localizations.myIdentityTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            title: context.localizations.myGenderLabel,
            subtitle: context.localizations.myGenderSubtitle,
            child: GenderSelector(
              selectedGender: _myGender,
              onChanged: (value) {
                setState(() => _myGender = value);
                _saveData();
              },
            ),
          ),
          _buildSection(
            title: context.localizations.myOrientationLabel,
            subtitle: context.localizations.myOrientationSubtitle,
            child: OrientationSelector(
              selectedOrientation: _myOrientation,
              onChanged: (value) async {
                setState(() => _myOrientation = value);
                _saveData();

                if (value != null && _myGender != null) {
                  final allGenders = await ReferenceDataService.fetchGenders();
                  final suggested = ReferenceDataService.suggestInterestedIn(
                    orientation: value,
                    myGender: _myGender!,
                    allGenders: allGenders,
                  );
                  if (suggested.isNotEmpty && mounted) {
                    _showSuggestionBanner(suggested);
                  }
                }
              },
            ),
          ),
          _buildSection(
            title: context.localizations.whoIWantToMeet,
            subtitle: context.localizations.whoIWantToMeetSubtitle,
            child: InterestedInSelector(
              selectedGenders: _interestedIn,
              onChanged: (value) {
                setState(() => _interestedIn = value);
                _saveData();
              },
            ),
          ),
        ],
      ),
    );
  }
}
