import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class ProfileDetailModal extends StatefulWidget {
  final String profileId;

  const ProfileDetailModal({super.key, required this.profileId});

  @override
  State<ProfileDetailModal> createState() => _ProfileDetailModalState();
}

class _ProfileDetailModalState extends State<ProfileDetailModal> {
  final supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>?> _fetchProfile() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('*, profile_tags(tags(name))')
          .eq('id', widget.profileId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const _ErrorView();
          }
          return _ProfileContentView(profile: snapshot.data!);
        },
      ),
    );
  }
}

// --- Views ---

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: const Text('Profil introuvable.', style: TextStyle(color: Colors.white)),
    );
  }
}

class _ProfileContentView extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ProfileContentView({required this.profile});

  @override
  Widget build(BuildContext context) {
    final interests = List<Map<String, dynamic>>.from(profile['profile_tags'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: CustomScrollView(
        slivers: [
          _SliverProfileHeader(profile: profile),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileDetails(profile: profile),
                      const SizedBox(height: 24),
                      _ProfileBio(bio: profile['bio'] ?? 'Aucune description.'),
                      if (interests.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _ProfileInterests(interests: interests),
                      ],
                      const SizedBox(height: 40),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Fermer', style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Components ---

class _SliverProfileHeader extends StatefulWidget {
  final Map<String, dynamic> profile;

  const _SliverProfileHeader({required this.profile});

  @override
  State<_SliverProfileHeader> createState() => _SliverProfileHeaderState();
}

class _SliverProfileHeaderState extends State<_SliverProfileHeader> {
  int _currentPhotoIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPhoto() {
    final photos = List<String>.from(widget.profile['photos'] ?? []);
    if (_currentPhotoIndex < photos.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _previousPhoto() {
    if (_currentPhotoIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = List<String>.from(widget.profile['photos'] ?? []);
    final fullName = widget.profile['full_name'] ?? 'Utilisateur';

    return SliverAppBar(
      expandedHeight: 450.0,
      backgroundColor: Colors.transparent,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // --- Le PageView pour les photos (gère le swipe) ---
            PageView.builder(
              controller: _pageController,
              itemCount: photos.isNotEmpty ? photos.length : 1,
              onPageChanged: (index) => setState(() => _currentPhotoIndex = index),
              itemBuilder: (context, index) {
                final url = photos.isNotEmpty ? photos[index] : "https://via.placeholder.com/400x400?text=No+Photo";
                return Image.network(url, fit: BoxFit.cover);
              },
            ),
            
            // --- Le dégradé pour la lisibilité du texte ---
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54, Colors.black],
                  stops: [0.5, 0.8, 1.0],
                ),
              ),
            ),
            
            // --- Zones de clic invisibles (gère le tap) ---
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _previousPhoto,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextPhoto,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),

            // --- Le contenu UI (nom, indicateurs) ---
            Positioned(
              bottom: 16,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8)],
                    ),
                  ),
                  if (photos.length > 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(photos.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentPhotoIndex == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white.withOpacity(_currentPhotoIndex == index ? 0.9 : 0.4),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ProfileDetails({required this.profile});

  @override
  Widget build(BuildContext context) {
    final gender = profile['gender'] ?? 'Non précisé';
    final city = profile['city'] ?? 'Non précisée';
    final birthDate = profile['birth_date'] != null
        ? '${(DateTime.now().difference(DateTime.parse(profile['birth_date'])).inDays / 365).floor()} ans'
        : 'Âge non précisé';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _InfoTile(icon: Icons.person_outline, value: gender),
        _InfoTile(icon: Icons.cake_outlined, value: birthDate),
        if (city.isNotEmpty) _InfoTile(icon: Icons.location_on_outlined, value: city),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoTile({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}

class _ProfileBio extends StatelessWidget {
  final String bio;

  const _ProfileBio({required this.bio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À propos',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          bio,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, height: 1.5),
        ),
      ],
    );
  }
}

class _ProfileInterests extends StatelessWidget {
  final List<Map<String, dynamic>> interests;

  const _ProfileInterests({required this.interests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Intérêts',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: interests
              .map((interest) {
                    final tagName = interest['tags']?['name'] ?? 'N/A';
                    return Chip(
                      label: Text(tagName),
                      backgroundColor: const Color(0xFF2C2C3E),
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  })
              .toList(),
        ),
      ],
    );
  }
}
