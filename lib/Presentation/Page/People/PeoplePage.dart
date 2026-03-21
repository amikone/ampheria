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

  List<Map<String, dynamic>> _profiles = [];
  int _currentIndex = 0;
  int _currentPhotoIndex = 0;

  bool _loading = true;
  bool _loadingMore = false;
  bool _isVerified = false;

  Map<String, dynamic>? get _currentProfile =>
      (_currentIndex < _profiles.length) ? _profiles[_currentIndex] : null;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select('verified')
          .eq('id', userId)
          .single() as Map<String, dynamic>?;

      if (mounted) {
        final isVerified = profile?['verified'] ?? false;
        setState(() {
          _isVerified = isVerified;
        });

        if (isVerified) {
          _loadProfiles();
        } else {
          setState(() => _loading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        //_handleError("Erreur lors de la vérification du profil");
        setState(() => _loading = false);
      }
    }
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
      final response = await supabase.rpc("get_next_profiles", params: {
        'p_limit': limit,
      });

      final data = response as List<dynamic>?;

      if (mounted) {
        if (data != null && data.isNotEmpty) {
          final incoming =
          data.map((e) => Map<String, dynamic>.from(e)).toList();
          setState(() {
            if (append) {
              _profiles.addAll(incoming);
              _loadingMore = false;
            } else {
              _profiles = incoming;
            }
            _loading = false;
          });
        } else {
          //_handleError("Aucun profil trouvé");
          setState(() => _loading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
        //_handleError("Erreur lors du chargement des profils");
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
      _currentPhotoIndex =
          (_currentPhotoIndex - 1 + photos.length) % photos.length;
    });
  }

  Future<void> _handleLike() async {
    final profile = _currentProfile;
    if (profile == null) return;
    try {
      await supabase.functions.invoke(
        'like-user',
        body: {'liked_id': profile['id']},
      );
    } catch (e) {
      if (mounted) {
        //_handleError("Erreur lors du like");
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
    _ensureBuffer();
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
    if (_loading) return const _LoadingView();
    if (!_isVerified) return const _VerificationPendingView();
    if (_currentProfile == null) {
      return _NoProfileView(onReload: _initializePage);
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

// NOUVEAU WIDGET
class _VerificationPendingView extends StatelessWidget {
  const _VerificationPendingView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_moon_outlined,
                size: 60, color: Colors.deepPurpleAccent),
            const SizedBox(height: 24),
            const Text(
              "Vérification en cours",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Ton compte n’a pas encore été validé. Nous vérifions les comptes au plus vite afin d’éviter les bots. Cela devrait prendre environ 24 heures. N’hésite pas à bien compléter ton profil pour accélérer le processus.",
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87
                    ],
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
        ? (DateTime.now()
                    .difference(DateTime.parse(profile['birth_date']))
                    .inDays /
                365)
            .floor()
        : null;
    final displayName =
        "${profile['full_name'] ?? profile['username']}${age != null ? ', $age' : ''}";
    final interests =
        List<Map<String, dynamic>>.from(profile['profile_tags'] ?? []);
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
        final tagName = interest['name'] ?? 'N/A';
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