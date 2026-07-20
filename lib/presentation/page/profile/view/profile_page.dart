import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ampheria/services/reference_data_service.dart';
import 'package:ampheria/presentation/widgets/orientation_selector.dart';
import 'package:ampheria/extensions/context_extension.dart';

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

  String? _myGender;
  String? _myOrientation;
  List<String> _interestedIn = [];
  double _minAge = 18;
  double _maxAge = 35;
  double _maxDistance = 50;

  List<String> _tags = [];

  TextEditingController? _autocompleteController;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
        SnackBar(content: Text(context.localizations.maxPhotosError)),
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
        SnackBar(content: Text(context.localizations.imageTooLargeError)),
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
          SnackBar(content: Text(context.localizations.imageAddedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.localizations.error(e.toString()))),
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
          SnackBar(content: Text(context.localizations.photoDeletedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${context.localizations.photoDeleteError} $e")),
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
          SnackBar(content: Text("${context.localizations.tagAddError} $e")),
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
              title: Text(context.localizations.changePasswordTitle, style: const TextStyle(color: Colors.white)),
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
                        labelText: context.localizations.newPasswordLabel,
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                      ),
                      validator: (value) => value == null || value.length < 6 ? context.localizations.passwordMinLengthError : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: context.localizations.confirmPasswordLabel,
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                      ),
                      validator: (value) => value != passwordController.text ? context.localizations.passwordsDoNotMatchError : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.localizations.cancel, style: const TextStyle(color: Colors.white70)),
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
                            SnackBar(content: Text(context.localizations.passwordUpdatedSuccess), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.localizations.error(e.toString())), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        setStateDialog(() => isUpdatingPassword = false);
                      }
                    }
                  },
                  child: isUpdatingPassword
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text(context.localizations.validate, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    bool isDeleting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(context.localizations.deleteAccountTitle, style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                context.localizations.deleteAccountWarning,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  child: Text(context.localizations.cancel, style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isDeleting ? null : () async {
                    setStateDialog(() => isDeleting = true);
                    try {
                      await supabase.rpc('delete_user');
                      await supabase.auth.signOut();

                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/login');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(context.localizations.accountDeletedSuccess),
                              backgroundColor: Colors.green
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.localizations.error(e.toString())), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      if (mounted) setStateDialog(() => isDeleting = false);
                    }
                  },
                  child: isDeleting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(context.localizations.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
            border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5), width: 3),
          ),
          child: CircleAvatar(
            radius: 48,
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
          _buildSectionTitle(context.localizations.aboutMeTitle, Icons.person_outline),
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
              hintText: context.localizations.aboutMeHint,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurpleAccent.withOpacity(0.15),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.6), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.localizations.myPassionsTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            context.localizations.passionsDescription,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),

          Autocomplete<Map<String, dynamic>>(
            displayStringForOption: (option) => option['name'] as String,
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<Map<String, dynamic>>.empty();
              return _searchTags(textEditingValue.text);
            },
            onSelected: (selection) {
              _addTag(selection['name'] as String);

              Future.delayed(Duration.zero, () {
                _autocompleteController?.clear();
              });
            },
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
                            "${option['count']} ${context.localizations.followersCount}",
                            style: const TextStyle(fontSize: 12, color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
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
              _autocompleteController = controller;

              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: context.localizations.passionsHint,
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black45,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                  ),
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
            const SizedBox(height: 20),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: _tags.map((tag) => _buildPremiumTag(tag)).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPremiumTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurpleAccent.withOpacity(0.8),
            const Color(0xFF9C27B0).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context.localizations.myPhotosTitle, Icons.photo_library_outlined),
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

  Widget _buildPreferencesSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context.localizations.datingPreferencesTitle, Icons.tune),

          Text(
            context.localizations.myOrientationLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.localizations.displayedOnPublicProfile,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),

          OrientationSelector(
            selectedOrientation: _myOrientation,
            onChanged: (value) async {
              setState(() => _myOrientation = value);
              _onProfileChanged();

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

          Text(
            context.localizations.iWantToMeetLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.localizations.usedByAlgorithmForProfiles,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.localizations.ageRangeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                "${_minAge.round()} - ${_maxAge.round()} ${context.localizations.ageYears}",
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.localizations.maxDistanceLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                "${_maxDistance.round()} ${context.localizations.distanceKm}",
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

  void _showSuggestionBanner(List<String> suggested) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF1E1B2E),
        content: Text(
          '${context.localizations.applySuggestionPrompt} ${suggested.join(', ')} ?',
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
            child: Text(
              context.localizations.ignore,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _interestedIn = suggested);
              _onPreferencesChanged();
              ScaffoldMessenger.of(context)
                  .hideCurrentMaterialBanner();
            },
            child: Text(
              context.localizations.apply,
              style: const TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(context.localizations.profileTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            color: const Color(0xFF1E1B2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'password') {
                _showChangePasswordDialog();
              } else if (value == 'delete') {
                _showDeleteAccountDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'password',
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Text(context.localizations.changePasswordTitle, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 12),
                    Text(context.localizations.deleteMyAccount, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
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

            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: Text(context.localizations.logout, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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