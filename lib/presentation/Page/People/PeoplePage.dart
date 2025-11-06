import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Widgets/ProfileDetailModal.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  int _currentPhotoIndex = 0;
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
    });

    try {
      final response = await supabase.functions.invoke('get-random-users');
      if (mounted) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          setState(() {
            _profile = response.data;
            _loading = false;
          });
        } else {
          _handleError("Aucun profil trouvé");
        }
      }
    } catch (e) {
      if (mounted) {
        _handleError("Erreur lors du chargement du profil");
      }
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() => _loading = false);
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
      _currentPhotoIndex = (_currentPhotoIndex - 1 + photos.length) % photos.length;
    });
  }

  Future<void> _handleLike() async {
    if (_profile == null) return;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase.functions.invoke(
        'like-user',
        body: {'liked_id': _profile!['id']},
      );
      final data = response.data as Map<String, dynamic>?;

      if (mounted) {
        if (data != null && data['matched'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("💘 C’est un match avec ${_profile!['username']} !")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("💖 Tu as liké ${_profile!['username']}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _handleError("Erreur lors du like");
      }
    }

    _loadRandomProfile();
  }

  void _handleDislike() {
    if (_profile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Tu as passé ${_profile!['username']}")),
      );
    }
    _loadRandomProfile();
  }

  void _showProfileDetails() {
    if (_profile != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProfileDetailModal(profileId: _profile!['id']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Darker background
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const _LoadingView();
    }

    if (_profile == null) {
      return _NoProfileView(onReload: _loadRandomProfile);
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _ProfileCard(
              profile: _profile!,
              currentPhotoIndex: _currentPhotoIndex,
              onNextPhoto: _nextPhoto,
              onPreviousPhoto: _previousPhoto,
            ),
          ),
        ),
        _ActionToolbar(
          onLike: _handleLike,
          onDislike: _handleDislike,
          onShowDetails: _showProfileDetails,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ));
  }
}

class _NoProfileView extends StatelessWidget {
  final VoidCallback onReload;

  const _NoProfileView({required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Plus de profils pour le moment.", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: onReload,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Recharger", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final int currentPhotoIndex;
  final VoidCallback onNextPhoto;
  final VoidCallback onPreviousPhoto;

  const _ProfileCard({
    required this.profile,
    required this.currentPhotoIndex,
    required this.onNextPhoto,
    required this.onPreviousPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final photos = List<String>.from(profile['photos'] ?? []);
    final currentPhoto = photos.isNotEmpty
        ? photos[currentPhotoIndex]
        : "https://via.placeholder.com/400x600?text=No+Photo";

    return GestureDetector(
      onTapUp: (details) {
        final width = MediaQuery.of(context).size.width;
        if (details.localPosition.dx < width / 3) {
          onPreviousPhoto();
        } else if (details.localPosition.dx > width * 2 / 3) {
          onNextPhoto();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with fade transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.network(
                currentPhoto,
                key: ValueKey<String>(currentPhoto),
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            // Gradient overlay for text readability
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            // Photo progress indicators
            if (photos.length > 1)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: _PhotoProgressIndicator(
                  photoCount: photos.length,
                  currentPhotoIndex: currentPhotoIndex,
                ),
              ),
            // Profile info overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _ProfileInfoOverlay(profile: profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoProgressIndicator extends StatelessWidget {
  final int photoCount;
  final int currentPhotoIndex;

  const _PhotoProgressIndicator({
    required this.photoCount,
    required this.currentPhotoIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(photoCount, (index) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            height: 3.0,
            decoration: BoxDecoration(
              color: index == currentPhotoIndex
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        );
      }),
    );
  }
}

class _ProfileInfoOverlay extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ProfileInfoOverlay({required this.profile});

  @override
  Widget build(BuildContext context) {
    final age = profile['birth_date'] != null ?
    (DateTime.now().difference(DateTime.parse(profile['birth_date'])).inDays / 365).floor() : '';

    final displayName = "${profile['full_name'] ?? profile['username']}${age.toString().isNotEmpty ? ', $age' : ''}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
          ),
        ),
        const SizedBox(height: 8),
        if (profile['city'] != null)
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                profile['city'],
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Text(
          profile['bio'] ?? 'Aucune description',
          style: const TextStyle(color: Colors.white, fontSize: 15),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ActionToolbar extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onShowDetails;

  const _ActionToolbar({
    required this.onLike,
    required this.onDislike,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.close,
          color: const Color(0xFFE57373), // Softer Red
          onPressed: onDislike,
        ),
        _buildActionButton(
            icon: Icons.info_outline,
            color: const Color(0xFF64B5F6), // Softer Blue
            onPressed: onShowDetails,
            isSmall: true
        ),
        _buildActionButton(
          icon: Icons.favorite,
          color: const Color(0xFF81C784), // Softer Green
          onPressed: onLike,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isSmall = false,
  }) {
    final size = isSmall ? 50.0 : 70.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2C2C2E),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        iconSize: size / 2.2,
        onPressed: onPressed,
      ),
    );
  }
}
