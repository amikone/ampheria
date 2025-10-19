import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  int _currentPhotoIndex = 0;
  bool _showBio = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomProfile();
  }

  Future<void> _loadRandomProfile() async {
    setState(() {
      _loading = true;
      _currentPhotoIndex = 0;
      _showBio = false;
    });

    final response = await supabase.functions.invoke('get-random-users');

    if (response.data != null && response.data is Map<String, dynamic>) {
      setState(() {
        _profile = response.data;
        _loading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun profil trouvé")),
      );
      setState(() => _loading = false);
    }
  }

  void _nextPhoto() {
    if (_profile == null) return;
    final photos = List<String>.from(_profile!['photos'] ?? []);
    if (photos.isEmpty) return;

    setState(() {
      _currentPhotoIndex = (_currentPhotoIndex + 1) % photos.length;
    });
  }

  void _previousPhoto() {
    if (_profile == null) return;
    final photos = List<String>.from(_profile!['photos'] ?? []);
    if (photos.isEmpty) return;

    setState(() {
      _currentPhotoIndex =
          (_currentPhotoIndex - 1 + photos.length) % photos.length;
    });
  }

  Future<void> _handleLike() async {
    if (_profile == null) return;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase.functions.invoke(
      'like-user',
      body: {'liked_id': _profile!['id']},
    );

    final data = response.data as Map<String, dynamic>?;

    if (data != null && data['matched'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("💘 C’est un match avec ${_profile!['username']} !")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("💖 Tu as liké ${_profile!['username']}")),
      );
    }

    _loadRandomProfile();
  }


  void _handleDislike() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Tu as passé ${_profile!?['username']}")),
    );
    _loadRandomProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _loadRandomProfile,
            child: const Text("Recharger un profil"),
          ),
        ),
      );
    }

    final photos = List<String>.from(_profile!['photos'] ?? []);
    final currentPhoto = photos.isNotEmpty
        ? photos[_currentPhotoIndex]
        : "https://via.placeholder.com/400x400?text=No+Photo";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapUp: (details) {
            final width = MediaQuery.of(context).size.width;
            if (details.localPosition.dx < width / 2) {
              _previousPhoto();
            } else {
              _nextPhoto();
            }
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 1000) {
              setState(() => _showBio = !_showBio);
            }
          },
          child: Stack(
            children: [
              // 🖼️ Photo
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Image.network(
                    currentPhoto,
                    key: ValueKey(currentPhoto),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 🧾 Overlay bio
              if (_showBio)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _profile!['full_name'] ?? _profile!['username'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _profile!['city'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _profile!['bio'] ?? 'Aucune description',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // ❤️ / ❌ boutons
              Positioned(
                bottom: 40,
                left: 40,
                right: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      heroTag: "dislike",
                      backgroundColor: Colors.redAccent,
                      onPressed: _handleDislike,
                      child: const Icon(Icons.close, size: 32),
                    ),
                    FloatingActionButton(
                      heroTag: "like",
                      backgroundColor: Colors.green,
                      onPressed: _handleLike,
                      child: const Icon(Icons.favorite, size: 32),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
