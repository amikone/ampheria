import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Services/ReferenceDataService.dart';
import '../../Widgets/OrientationSelector.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  Timer? _debounce;

  // --- State Variables ---
  String _bio = '';
  String _name = '';
  List<String> _photos = [];

  String? _myGender;
  String? _myOrientation;
  List<String> _interestedIn = [];
  double _minAge = 18;
  double _maxAge = 35;
  double _maxDistance = 50;

  List<String> _tags = [];
  final _tagController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tagController.dispose();
    _saveProfile();
    _savePreferences();
    super.dispose();
  }

  // ==========================================
  // LOGIC & API CALLS
  // ==========================================

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadProfile(),
      _loadPreferences(),
      _loadUserTags(),
    ]);
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select('bio, full_name, photos, gender, orientation')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted && response != null) {
      setState(() {
        _bio         = response['bio'] ?? '';
        _name        = response['full_name'] ?? '';
        _photos      = List<String>.from(response['photos'] ?? []);
        _myGender    = response['gender'];
        _myOrientation = response['orientation'];
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_loading) return;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase.from('profiles').update({
      'bio':         _bio,
      'photos':      _photos,
      'orientation': _myOrientation,
      'updated_at':  DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }

  void _onProfileChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      _saveProfile();
    });
  }

  Future<void> _pickAndUploadPhoto() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_photos.length >= 8) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous ne pouvez pas avoir plus de 8 photos.")),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 80,
    );

    if (compressedBytes == null) return;

    const maxSize = 2 * 1024 * 1024;
    if (compressedBytes.length > maxSize) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'image dépasse 2 Mo")),
      );
      return;
    }

    try {
      final response = await supabase.functions.invoke(
        'upload-profile-photo',
        body: {'file_data': compressedBytes},
      );

      final data = response.data as Map<String, dynamic>;
      final imageUrl = data['url'];

      setState(() => _photos.add(imageUrl));
      await _saveProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image ajoutée !")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e")),
        );
      }
    }
  }

  Future<void> _removePhoto(String url) async {
    try {
      final parts = url.split('/profiles-picture/');
      if (parts.length < 2) return;
      final path = parts.last;

      await supabase.storage.from('profiles-picture').remove([path]);

      setState(() => _photos.remove(url));
      await _saveProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo supprimée")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la suppression: $e")),
        );
      }
    }
  }

  Future<void> _loadUserTags() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profile_tags')
        .select('tags(name)')
        .eq('profile_id', user.id);

    if (mounted) {
      setState(() {
        _tags = List<String>.from(response.map((e) => e['tags']['name']));
      });
    }
  }

  Future<List<Map<String, dynamic>>> _searchTags(String query) async {
    if (query.isEmpty) return [];

    final response = await supabase
        .from('tags')
        .select('name, usage_count')
        .ilike('name', '%$query%')
        .order('usage_count', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(response.map((tag) => {
      'name': tag['name'],
      'count': tag['usage_count'] ?? 0,
    }));
  }

  Future<void> _addTag(String tagName) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final cleanName = tagName.trim().toLowerCase();
    if (cleanName.isEmpty || _tags.contains(cleanName)) return;

    setState(() {
      _tags.add(cleanName);
      _tagController.clear();
    });

    try {
      int tagId;
      final existingTag = await supabase
          .from('tags')
          .select('id')
          .eq('name', cleanName)
          .maybeSingle();

      if (existingTag != null) {
        tagId = existingTag['id'];
      } else {
        final newTag = await supabase
            .from('tags')
            .insert({'name': cleanName})
            .select('id')
            .single();
        tagId = newTag['id'];
      }

      await supabase.from('profile_tags').upsert({
        'profile_id': user.id,
        'tag_id': tagId,
      });
    } catch (e) {
      if (mounted) {
        setState(() => _tags.remove(cleanName));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout du tag : $e")),
        );
      }
    }
  }

  Future<void> _removeTag(String tagName) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final originalTags = List<String>.from(_tags);
    setState(() => _tags.remove(tagName));

    try {
      final tagResponse = await supabase
          .from('tags')
          .select('id')
          .eq('name', tagName)
          .single();

      final tagId = tagResponse['id'];

      await supabase
          .from('profile_tags')
          .delete()
          .eq('profile_id', user.id)
          .eq('tag_id', tagId);
    } catch (e) {
      setState(() => _tags = originalTags);
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

    if (mounted && response != null) {
      setState(() {
        _interestedIn = List<String>.from(response['interested_in'] ?? []);
        _minAge = (response['min_age'] ?? 18).toDouble();
        _maxAge = (response['max_age'] ?? 35).toDouble();
        _maxDistance = (response['max_distance_km'] ?? 50).toDouble();
      });
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
  }

  void _onPreferencesChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      _savePreferences();
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _showChangePasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isUpdatingPassword = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Changer le mot de passe', style: TextStyle(color: Colors.white)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                      ),
                      validator: (value) => value == null || value.length < 6 ? 'Au moins 6 caractères requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirmer',
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                      ),
                      validator: (value) => value != passwordController.text ? 'Les mots de passe diffèrent' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: isUpdatingPassword ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setStateDialog(() => isUpdatingPassword = true);
                      try {
                        await supabase.auth.updateUser(UserAttributes(password: passwordController.text));
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Mot de passe mis à jour !"), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur: ${e.toString()}"), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        setStateDialog(() => isUpdatingPassword = false);
                      }
                    }
                  },
                  child: isUpdatingPassword
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Valider', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // UI SECTIONS (Style "Premium Dark")
  // ==========================================

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20.0),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Retour de l'accent violet sur le contour de l'avatar
            border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5), width: 3),
          ),
          child: CircleAvatar(
            radius: 48,
            // Et sur le fond de l'avatar
            backgroundColor: Colors.deepPurpleAccent,
            child: Text(
              _name.isNotEmpty ? _name.substring(0, 1).toUpperCase() : "?",
              style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBioSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("À propos de moi", Icons.person_outline),
          TextFormField(
            initialValue: _bio,
            maxLines: 3,
            maxLength: 250,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: "Parle un peu de toi...",
              hintStyle: const TextStyle(color: Colors.white38),
              counterStyle: const TextStyle(color: Colors.white54),
            ),
            onChanged: (value) {
              _bio = value;
              _onProfileChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPassionsSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Mes passions", Icons.favorite_outline),
          Autocomplete<Map<String, dynamic>>(
            displayStringForOption: (option) => option['name'] as String,
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<Map<String, dynamic>>.empty();
              return _searchTags(textEditingValue.text);
            },
            onSelected: (selection) => _addTag(selection['name'] as String),
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: const Color(0xFF1E1E1E),
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option['name'] as String, style: const TextStyle(color: Colors.white)),
                          trailing: Text(
                              "${option['count']} personne(s)",
                              style: const TextStyle(fontSize: 12, color: Colors.white54)
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ajouter une passion...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.deepPurpleAccent),
                    onPressed: () {
                      _addTag(controller.text.trim());
                      controller.clear();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _addTag(value.trim());
                  controller.clear();
                },
              );
            },
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _tags.map((tag) => Chip(
                // Retour du violet sur les tags (texte et bordure)
                label: Text(tag, style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
                onDeleted: () => _removeTag(tag),
                deleteIconColor: Colors.deepPurpleAccent,
                backgroundColor: Colors.deepPurpleAccent.withOpacity(0.15),
                side: const BorderSide(color: Colors.deepPurpleAccent, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              )).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Mes photos", Icons.photo_library_outlined),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _photos.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                return InkWell(
                  onTap: _pickAndUploadPhoto,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.white70, size: 32),
                  ),
                );
              }

              final photoUrl = _photos[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(photoUrl, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon: Container(
                        decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                      onPressed: () => _removePhoto(photoUrl),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }







// Nouvelle section préférences complète
  Widget _buildPreferencesSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Préférences de rencontre", Icons.tune),

          // --- MON ORIENTATION (affichage profil) ---
          const Text(
            'Mon orientation sexuelle',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Affiché sur ton profil public',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),

          OrientationSelector(
            selectedOrientation: _myOrientation,
            onChanged: (value) async {
              setState(() => _myOrientation = value);
              _onProfileChanged();

              // Auto-suggestion de interested_in
              if (value != null && _myGender != null) {
                final allGenders =
                await ReferenceDataService.fetchGenders();
                final suggested =
                ReferenceDataService.suggestInterestedIn(
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

          const Divider(height: 40, color: Colors.white24),

          // --- JE VEUX RENCONTRER (algorithme) ---
          const Text(
            'Je souhaite rencontrer',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Utilisé par l\'algorithme pour te montrer des profils',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),

          FutureBuilder<List<String>>(
            future: ReferenceDataService.fetchGenders(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
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
                children: snapshot.data!.map((gender) {
                  final isSelected = _interestedIn.contains(gender);
                  return FilterChip(
                    label: Text(
                      gender,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor:
                    Colors.deepPurpleAccent.withOpacity(0.3),
                    checkmarkColor: Colors.deepPurpleAccent,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.deepPurpleAccent
                          : Colors.white.withOpacity(0.2),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _interestedIn.add(gender)
                            : _interestedIn.remove(gender);
                      });
                      _onPreferencesChanged();
                    },
                  );
                }).toList(),
              );
            },
          ),

          const Divider(height: 40, color: Colors.white24),

          // --- ÂGE ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tranche d'âge",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                "${_minAge.round()} - ${_maxAge.round()} ans",
                style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          RangeSlider(
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.deepPurpleAccent.withOpacity(0.2),
            min: 18,
            max: 99,
            divisions: 81,
            values: RangeValues(_minAge, _maxAge),
            onChanged: (values) => setState(() {
              _minAge = values.start;
              _maxAge = values.end;
            }),
            onChangeEnd: (_) => _onPreferencesChanged(),
          ),

          const Divider(height: 40, color: Colors.white24),

          // --- DISTANCE ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Distance maximale",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                "${_maxDistance.round()} km",
                style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.deepPurpleAccent.withOpacity(0.2),
            min: 1,
            max: 200,
            divisions: 199,
            value: _maxDistance,
            onChanged: (value) =>
                setState(() => _maxDistance = value),
            onChangeEnd: (_) => _onPreferencesChanged(),
          ),
        ],
      ),
    );
  }

// Banner de suggestion non-invasive
  void _showSuggestionBanner(List<String> suggested) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF1E1B2E),
        content: Text(
          'Appliquer la suggestion : ${suggested.join(', ')} ?',
          style: const TextStyle(color: Colors.white70),
        ),
        leading: const Icon(
          Icons.auto_awesome,
          color: Colors.deepPurpleAccent,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .hideCurrentMaterialBanner();
            },
            child: const Text(
              'Ignorer',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _interestedIn = suggested);
              _onPreferencesChanged();
              ScaffoldMessenger.of(context)
                  .hideCurrentMaterialBanner();
            },
            child: const Text(
              'Appliquer',
              style: TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MAIN BUILD METHOD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fond noir profond coordonné avec PeoplePage
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Changer le mot de passe',
            onPressed: _showChangePasswordDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _buildProfileHeader(),
            _buildBioSection(),
            const SizedBox(height: 16),
            _buildPassionsSection(),
            const SizedBox(height: 16),
            _buildPhotosSection(),
            const SizedBox(height: 16),
            _buildPreferencesSection(),
            const SizedBox(height: 40),

            // Bouton de déconnexion stylisé pour le mode sombre
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}