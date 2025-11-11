import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  Timer? _debounce;

  String _bio = '';
  String _name = '';
  List<String> _photos = [];

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
        .select('bio, full_name, photos')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted && response != null) {
      setState(() {
        _bio = response['bio'] ?? '';
        _name = response['full_name'] ?? '';
        _photos = List<String>.from(response['photos'] ?? []);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_loading) return;
    
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').update({
      'bio': _bio,
      'photos': _photos,
      'updated_at': DateTime.now().toIso8601String(),
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
      debugPrint("Erreur lors de l'appel à la fonction: $e");
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
      debugPrint("Erreur suppression image: $e");
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

  Future<List<String>> _searchTags(String query) async {
    if (query.isEmpty) return [];
    final response = await supabase
        .from('tags')
        .select('name')
        .ilike('name', '%$query%')
        .limit(10);
    return List<String>.from(response.map((e) => e['name']));
  }

  Future<void> _addTag(String tagName) async {
    if (tagName.isEmpty || _tags.contains(tagName)) return;
    
    final user = supabase.auth.currentUser;
    if (user == null) return;
    
    setState(() => _tags.add(tagName));
    _tagController.clear();

    try {
      final tagResponse = await supabase
          .from('tags')
          .select('id')
          .eq('name', tagName)
          .maybeSingle();

      int tagId;
      if (tagResponse != null) {
        tagId = tagResponse['id'];
      } else {
        final newTag = await supabase
            .from('tags')
            .insert({'name': tagName})
            .select('id')
            .single();
        tagId = newTag['id'];
      }

      await supabase.from('profile_tags').upsert({
        'profile_id': user.id,
        'tag_id': tagId,
      });
    } catch(e) {
       debugPrint("Erreur ajout tag: $e");
       setState(() => _tags.remove(tagName));
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
    } catch(e) {
      debugPrint("Erreur suppression tag: $e");
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
                      _name.substring(0, 1).toUpperCase() ?? "?",
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      _name,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Mes passions",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _searchTags(textEditingValue.text);
                    },
                    onSelected: (String selection) => _addTag(selection),
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      _tagController.addListener(() {
                        controller.text = _tagController.text;
                        controller.selection = _tagController.selection;
                      });

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Ajouter une passion...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addTag(controller.text.trim()),
                          ),
                        ),
                        onEditingComplete: () {
                          onEditingComplete();
                           _addTag(controller.text.trim());
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                      deleteIconColor: Colors.deepPurple,
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    )).toList(),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    "Ma description",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _bio,
                    maxLines: 3,
                    maxLength: 250,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Parle un peu de toi...",
                    ),
                    onChanged: (value) {
                      _bio = value;
                      _onProfileChanged();
                    },
                  ),
                  const SizedBox(height: 24),

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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),

                  const Text(
                    "Préférences de rencontre",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text("Genre(s) recherché(s)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            _onPreferencesChanged();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  const Text("Tranche d'âge", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RangeSlider(
                    min: 18,
                    max: 99,
                    divisions: 81,
                    labels: RangeLabels("${_minAge.round()}", "${_maxAge.round()}"),
                    values: RangeValues(_minAge, _maxAge),
                    onChanged: (values) {
                      setState(() {
                        _minAge = values.start;
                        _maxAge = values.end;
                      });
                    },
                    onChangeEnd: (values) {
                       _onPreferencesChanged();
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text("Distance maximale (km)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Slider(
                    min: 1,
                    max: 200,
                    divisions: 199,
                    label: "${_maxDistance.round()} km",
                    value: _maxDistance,
                    onChanged: (value) => setState(() => _maxDistance = value),
                    onChangeEnd: (value) {
                       _onPreferencesChanged();
                    },
                  ),
                  const SizedBox(height: 48),

                  ElevatedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
