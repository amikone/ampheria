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

  // Nouveau: buffer de profils
  List<Map<String, dynamic>> _profiles = [];
  int _currentIndex = 0;

  // Index de la photo pour le profil courant
  int _currentPhotoIndex = 0;

  bool _loading = true;
  bool _loadingMore = false;

  Map<String, dynamic>? get _currentProfile =>
      (_currentIndex < _profiles.length) ? _profiles[_currentIndex] : null;

  @override
  void initState() {
    super.initState();
    _loadProfiles(); // charge 10 par défaut
  }

  Future<void> _loadProfiles({bool append = false, int limit = 10}) async {
    if (!append) {
      setState(() {
        _loading = true;
        _currentIndex = 0;
        _currentPhotoIndex = 0;
      });
    } else {
      if (_loadingMore) return;
      setState(() => _loadingMore = true);
    }

    try {
      final response = await supabase.functions.invoke(
        'get-random-users',
        body: {'limit': limit},
      );

      final data = response.data;

      if (mounted) {
        if (data is List) {
          final incoming = data.cast<Map<String, dynamic>>();
          setState(() {
            if (append) {
              _profiles.addAll(incoming);
              _loadingMore = false;
            } else {
              _profiles = incoming;
              _loading = false;
            }
          });
        } else {
          _handleError("Aucun profil trouvé");
        }
      }
    } catch (e) {
      if (mounted) {
        _handleError("Erreur lors du chargement des profils");
      }
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _loading = false;
      _loadingMore = false;
    });
  }

  // Préchargement quand il reste peu de profils
  void _ensureBuffer() {
    const threshold = 3;
    if (!_loadingMore &&
        _profiles.length - _currentIndex <= threshold &&
        !_loading) {
      _loadProfiles(append: true, limit: 10);
    }
  }

  void _nextPhoto() {
    final profile = _currentProfile;
    if (profile == null) return;
    final photos = List<String>.from(profile['photos'] ?? []);
    if (photos.isEmpty) return;
    setState(() {
      _currentPhotoIndex = (_currentPhotoIndex + 1) % photos.length;
    });
  }

  void _previousPhoto() {
    final profile = _currentProfile;
    if (profile == null) return;
    final photos = List<String>.from(profile['photos'] ?? []);
    if (photos.isEmpty) return;
    setState(() {
      _currentPhotoIndex = (_currentPhotoIndex - 1 + photos.length) % photos.length;
    });
  }

  Future<void> _handleLike() async {
    final profile = _currentProfile;
    if (profile == null) return;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      final response = await supabase.functions.invoke(
        'like-user',
        body: {'liked_id': profile['id']},
      );
      final data = response.data as Map<String, dynamic>?;
      if (mounted) {
        if (data != null && data['matched'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("💘 C’est un match avec ${profile['username']} !")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _handleError("Erreur lors du like");
      }
    }
    _goToNextProfile();
  }

  void _handleDislike() {
    _goToNextProfile();
  }

  void _goToNextProfile() {
    setState(() {
      _currentIndex++;
      _currentPhotoIndex = 0;
    });

    // Si plus de profils dans le buffer, relancer un fetch
    if (_currentProfile == null) {
      _loadProfiles();
    } else {
      _ensureBuffer();
    }
  }

  void _showProfileDetails() {
    final profile = _currentProfile;
    if (profile != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProfileDetailModal(profileId: profile['id']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const _LoadingView();
    }
    if (_currentProfile == null) {
      return _NoProfileView(onReload: () => _loadProfiles());
    }
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _ProfileCard(
              profile: _currentProfile!,
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
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
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
          const Text("Plus de profils pour le moment.",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: onReload,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Recharger",
                style: TextStyle(color: Colors.white, fontSize: 16)),
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
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
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
    final age = profile['birth_date'] != null
        ? (DateTime.now().difference(DateTime.parse(profile['birth_date'])).inDays / 365).floor()
        : null;
    final displayName =
        "${profile['full_name'] ?? profile['username']}${age != null ? ', $age' : ''}";
    final interests = List<Map<String, dynamic>>.from(profile['profile_tags'] ?? []);
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
        if (interests.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ProfileInterests(interests: interests.take(4).toList()),
        ],
      ],
    );
  }
}

class _ProfileInterests extends StatelessWidget {
  final List<Map<String, dynamic>> interests;
  const _ProfileInterests({required this.interests});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: interests.map((interest) {
        final tagName = interest['tags']?['name'] ?? 'N/A';
        return Chip(
          label: Text(tagName),
          backgroundColor: const Color(0xFF2C2C3E).withOpacity(0.8),
          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        );
      }).toList(),
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
          color: const Color(0xFFE57373),
          onPressed: onDislike,
        ),
        _buildActionButton(
          icon: Icons.info_outline,
          color: const Color(0xFF64B5F6),
          onPressed: onShowDetails,
          isSmall: true,
        ),
        _buildActionButton(
          icon: Icons.favorite,
          color: const Color(0xFF81C784),
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