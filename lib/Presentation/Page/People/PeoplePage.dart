import 'dart:ui';
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
          setState(() => _loading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
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

  void _handleLike() {
    final profile = _currentProfile;
    if (profile == null) return;

    final likedId = profile['id']; // Sauvegarde l'ID avant de passer au suivant

    _goToNextProfile(); // L'UI se met à jour instantanément !

    // La requête part en fond, sans bloquer l'écran
    supabase.functions.invoke(
      'like-user',
      body: {'liked_id': likedId},
    ).catchError((e) {
      debugPrint("Erreur lors du like: $e");
    });
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

    // Précharge l'image du prochain profil pour éviter un écran de chargement au swipe
    if (_currentIndex < _profiles.length) {
      final nextProfile = _profiles[_currentIndex];
      final photos = List<String>.from(nextProfile['photos'] ?? []);
      if (photos.isNotEmpty) {
        precacheImage(NetworkImage(photos.first), context);
      }
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
    if (_loading) return const _LoadingView();
    if (!_isVerified) return const _VerificationPendingView();

    // L'AnimatedSwitcher gère la transition en douceur quand _currentProfile devient null
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _currentProfile == null
          ? _NoProfileView(
        key: const ValueKey('empty_view'),
        onReload: _initializePage,
      )
          : Stack(
        key: const ValueKey('cards_view'), // Clé importante pour l'animation
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 85.0),
            child: SwipeableProfileCard(
              key: ValueKey(_currentProfile!['id']),
              onLike: _handleLike,
              onDislike: _handleDislike,
              child: _ProfileCard(
                profile: _currentProfile!,
                currentPhotoIndex: _currentPhotoIndex,
                onNextPhoto: _nextPhoto,
                onPreviousPhoto: _previousPhoto,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: _ProfileDetailButton(
                onPressed: _showProfileDetails,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- NOUVEAU : La carte rotative avec physique et labels visuels ---

class SwipeableProfileCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const SwipeableProfileCard({
    super.key,
    required this.child,
    required this.onLike,
    required this.onDislike,
  });

  @override
  State<SwipeableProfileCard> createState() => _SwipeableProfileCardState();
}

class _SwipeableProfileCardState extends State<SwipeableProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<Offset>? _moveAnimation; // Gère l'animation fluide

  Offset _offset = Offset.zero;
  double _angle = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Animation super rapide (250ms) pour un effet dynamique
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));

    _controller.addListener(() {
      if (_moveAnimation != null) {
        setState(() {
          _offset = _moveAnimation!.value;
          _angle = _offset.dx / MediaQuery.of(context).size.width * 0.5;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
      _angle = _offset.dx / MediaQuery.of(context).size.width * 0.5;
    });
  }

  // Crée l'animation de glissade (soit pour éjecter, soit pour revenir au centre)
  void _animateTo(Offset target, {VoidCallback? onComplete}) {
    _moveAnimation = Tween<Offset>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0).then((_) {
      if (onComplete != null) onComplete();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;

    if (_offset.dx > screenWidth * 0.30) {
      // Swipe Droite : on jette la carte loin à droite PUIS on appelle Like
      _animateTo(Offset(screenWidth * 1.5, _offset.dy), onComplete: widget.onLike);
    } else if (_offset.dx < -screenWidth * 0.30) {
      // Swipe Gauche : on jette la carte loin à gauche PUIS on appelle Dislike
      _animateTo(Offset(-screenWidth * 1.5, _offset.dy), onComplete: widget.onDislike);
    } else {
      // Annulé : Retour fluide au centre
      _animateTo(Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    final likeOpacity = (_offset.dx / 100).clamp(0.0, 1.0);
    final dislikeOpacity = (-_offset.dx / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: _angle,
          child: Stack(
            children: [
              widget.child,

              if (likeOpacity > 0)
                Positioned(
                  top: 50,
                  left: 30,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: _buildStamp("LIKE", const Color(0xFF4CAF50), likeOpacity),
                  ),
                ),

              if (dislikeOpacity > 0)
                Positioned(
                  top: 50,
                  right: 30,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: _buildStamp("NOPE", const Color(0xFFF44336), dislikeOpacity),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStamp(String text, Color color, double opacity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(opacity), width: 4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withOpacity(opacity),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// --- Bouton Infos (Pilule) ---

class _ProfileDetailButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ProfileDetailButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.black87, size: 22),
                SizedBox(width: 8),
                Text(
                  "Voir le profil",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Vues (inchangées) ---

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
            const Icon(Icons.shield_moon_outlined, size: 60, color: Colors.deepPurpleAccent),
            const SizedBox(height: 24),
            const Text(
              "Vérification en cours",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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

// --- Nouvelle vue "Plus de profils" avec animation Radar ---

class _NoProfileView extends StatefulWidget {
  final VoidCallback onReload;
  const _NoProfileView({super.key, required this.onReload});

  @override
  State<_NoProfileView> createState() => _NoProfileViewState();
}

class _NoProfileViewState extends State<_NoProfileView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Création d'une animation qui boucle (effet de respiration/pulse)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône animée
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_controller.value * 0.15), // Grandit de 15%
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1 + (_controller.value * 0.2)),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.wifi_tethering_rounded, // Icône style radar
                      size: 50,
                      color: Colors.white70,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              "Tu as fait le tour !",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Reviens plus tard pour découvrir de nouvelles personnes dans ton secteur.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Bouton de rechargement style Premium Mat
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              onPressed: widget.onReload,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Chercher à nouveau",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Carte et Infos (inchangées) ---

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
        // On garde le tap pour changer de photo (ça ne rentre pas en conflit avec le swipe qui utilise Pan)
        if (details.localPosition.dx < width / 3) {
          onPreviousPhoto();
        } else if (details.localPosition.dx > width * 2 / 3) {
          onNextPhoto();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
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
                        Colors.black45,
                        Colors.black87
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              if (photos.length > 1)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: _PhotoProgressIndicator(
                    photoCount: photos.length,
                    currentPhotoIndex: currentPhotoIndex,
                  ),
                ),
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: _ProfileInfoOverlay(profile: profile),
              ),
            ],
          ),
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
            height: 4.0,
            decoration: BoxDecoration(
              color: index == currentPhotoIndex
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
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

    final rawInterests = profile['tags'] ?? profile['profile_tags'] ?? [];
    final List<String> interests = [];
    for (var item in rawInterests) {
      if (item is String) {
        interests.add(item);
      } else if (item is Map && item['name'] != null) {
        interests.add(item['name']);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4.0, color: Colors.black87)],
          ),
        ),
        const SizedBox(height: 6),
        if (profile['city'] != null)
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                profile['city'],
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        const SizedBox(height: 12),
        Text(
          profile['bio'] ?? 'Aucune description',
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.4),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (interests.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ProfileInterests(interests: interests.take(4).toList()),
        ],
      ],
    );
  }
}

class _ProfileInterests extends StatelessWidget {
  final List<String> interests;
  const _ProfileInterests({required this.interests});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: interests.map((tagName) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.8), primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tag, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                tagName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}