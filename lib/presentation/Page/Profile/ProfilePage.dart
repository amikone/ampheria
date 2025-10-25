import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  List<String> _interestedIn = [];
  double _minAge = 18;
  double _maxAge = 35;
  double _maxDistance = 50;
  bool _loading = true;

  String _bio = '';
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPreferences();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select('bio, photos')
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      setState(() {
        _bio = response['bio'] ?? '';
        _photos = List<String>.from(response['photos'] ?? []);
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').update({
      'bio': _bio,
      'photos': _photos,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour !")),
      );
    }
  }

  Future<void> _loadPreferences() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('user_preferences')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (response != null) {
      setState(() {
        _interestedIn = List<String>.from(response['interested_in'] ?? []);
        _minAge = (response['min_age'] ?? 18).toDouble();
        _maxAge = (response['max_age'] ?? 35).toDouble();
        _maxDistance = (response['max_distance_km'] ?? 50).toDouble();
        _loading = false;
      });
    } else {
      await supabase.from('user_preferences').insert({
        'user_id': user.id,
        'interested_in': [],
        'min_age': 18,
        'max_age': 35,
        'max_distance_km': 50,
      });
      setState(() => _loading = false);
    }
  }

  Future<void> _savePreferences() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('user_preferences').upsert({
      'user_id': user.id,
      'interested_in': _interestedIn,
      'min_age': _minAge.round(),
      'max_age': _maxAge.round(),
      'max_distance_km': _maxDistance.round(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Préférences mises à jour !")),
      );
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);

    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final filePath = "${user.id}/$fileName";

    try {
      await supabase.storage
          .from('profiles-picture')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl =
      supabase.storage.from('profiles-picture').getPublicUrl(filePath);

      setState(() => _photos.add(publicUrl));

      await _saveProfile();
    } catch (e) {
      debugPrint("Erreur d'upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'upload de l'image: $e")),
      );
    }
  }

  Future<void> _removePhoto(String url) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final parts = url.split('/profiles-picture/');
      if (parts.length < 2) return;
      final path = parts.last;

      await supabase.storage.from('profiles-picture').remove([path]);

      setState(() => _photos.remove(url));
      await _saveProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo supprimée avec succès")),
      );
    } catch (e) {
      debugPrint("Erreur suppression image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression: $e")),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurple,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? "?",
                style:
                const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                user?.email ?? "N/A",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Section bio
            const Text(
              "Ma description",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Parle un peu de toi...",
              ),
              controller: TextEditingController(text: _bio),
              onChanged: (value) => _bio = value,
            ),
            const SizedBox(height: 12),

            // ✅ Section photos
            const Text(
              "Mes photos",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _photos.length + 1,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index == _photos.length) {
                  return GestureDetector(
                    onTap: _pickAndUploadPhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.deepPurple),
                    ),
                  );
                }

                final photoUrl = _photos[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(photoUrl, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(photoUrl),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer le profil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 🔽 Section préférences (inchangée)
            const Text(
              "Préférences de rencontre",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),

            const Text("Genre(s) recherché(s)",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ['male', 'female', 'other'].map((gender) {
                final isSelected = _interestedIn.contains(gender);
                return FilterChip(
                  label: Text(gender),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _interestedIn.add(gender);
                      } else {
                        _interestedIn.remove(gender);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text("Tranche d'âge",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            RangeSlider(
              min: 18,
              max: 99,
              divisions: 81,
              labels:
              RangeLabels("${_minAge.round()}", "${_maxAge.round()}"),
              values: RangeValues(_minAge, _maxAge),
              onChanged: (values) {
                setState(() {
                  _minAge = values.start;
                  _maxAge = values.end;
                });
              },
            ),
            const SizedBox(height: 24),

            const Text("Distance maximale (km)",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              min: 1,
              max: 200,
              divisions: 199,
              label: "${_maxDistance.round()} km",
              value: _maxDistance,
              onChanged: (value) =>
                  setState(() => _maxDistance = value),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _savePreferences,
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer mes préférences"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 48),

            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
