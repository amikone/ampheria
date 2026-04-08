import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          .rpc('get_profile_by_id', params: {'target_id': widget.profileId})
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error: $e');
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 400,
      child: Center(child: CircularProgressIndicator(color: primaryColor)),
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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Text('Profil introuvable.', style: TextStyle(fontSize: 16)),
    );
  }
}

class _ProfileContentView extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ProfileContentView({required this.profile});

  Widget _buildSectionTitle(String title, IconData icon, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tags = List<String>.from(profile['tags'] ?? []);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardRadius = 16.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _SliverProfileHeader(profile: profile),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _ProfileDetailsCard(
                    profile: profile,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardRadius)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("À propos", Icons.person_outline, primaryColor),
                          Text(
                            profile['bio'] ?? 'Aucune description.',
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cardRadius)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Intérêts", Icons.favorite_outline, primaryColor),
                            const SizedBox(height: 8), // Un peu d'air
                            Wrap(
                              spacing: 10.0, // Espace horizontal entre les tags
                              runSpacing: 12.0, // Espace vertical entre les lignes
                              children: tags.map((tagName) {
                                // --- LE NOUVEAU DESIGN FANCY DES TAGS ---
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    // Dégradé élégant
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor.withOpacity(0.7),
                                        primaryColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    // Ombre douce pour faire ressortir la bulle
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Petite icône optionnelle pour le style
                                      const Icon(
                                          Icons.tag,
                                          color: Colors.white70,
                                          size: 16
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        tagName,
                                        style: const TextStyle(
                                          color: Colors.white, // Blanc garanti !
                                          fontWeight: FontWeight.w600, // Texte un peu plus gras
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Fermer le profil',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Components ---

class _ProfileDetailsCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final Color primaryColor;
  final double cardRadius;

  const _ProfileDetailsCard({
    required this.profile,
    required this.primaryColor,
    required this.cardRadius,
  });

  String _getDisplayGender(String? gender) {
    switch (gender) {
      case 'male':
        return 'Homme';
      case 'female':
        return 'Femme';
      case 'other':
        return 'Autre';
      default:
        return 'Non précisé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gender = _getDisplayGender(profile['gender'] as String?);
    final city = profile['city'] ?? 'Non précisée';
    final birthDate = profile['birth_date'] != null
        ? '${(DateTime.now().difference(DateTime.parse(profile['birth_date'])).inDays / 365).floor()} ans'
        : 'Âge inconnu';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _InfoColumn(icon: Icons.person_outline, value: gender, color: primaryColor),
            Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
            _InfoColumn(icon: Icons.cake_outlined, value: birthDate, color: primaryColor),
            if (city.isNotEmpty && city != 'Non précisée') ...[
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
              _InfoColumn(icon: Icons.location_on_outlined, value: city, color: primaryColor),
            ]
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoColumn({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

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

  Future<void> _showReportDialog(BuildContext context, String reportedId) async {
    final textController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.flag_outlined, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Signaler ce profil'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Veuillez indiquer la raison de votre signalement :'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Faux profil, comportement inapproprié...',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    final reason = textController.text.trim();
                    if (reason.isEmpty) return;

                    setStateDialog(() => isSubmitting = true);

                    try {
                      final supabase = Supabase.instance.client;
                      final currentUser = supabase.auth.currentUser;

                      if (currentUser == null) throw Exception("Utilisateur non connecté");

                      await supabase.from('reports').upsert({
                        'reporter_id': currentUser.id,
                        'reported_id': reportedId,
                        'reason': reason,
                        'content_type': 'profile',
                      }, onConflict: 'reporter_id, reported_id');

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Le profil a été signalé avec succès.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      setStateDialog(() => isSubmitting = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors du signalement : $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Signaler'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = List<String>.from(widget.profile['photos'] ?? []);
    final fullName = widget.profile['full_name'] ?? 'Utilisateur';
    final profileId = widget.profile['id'];
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SliverAppBar(
      expandedHeight: 450.0,
      backgroundColor: Colors.transparent,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      actions: [
        if (profileId != null)
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.flag_outlined, color: Colors.white),
              tooltip: 'Signaler ce profil',
              onPressed: () => _showReportDialog(context, profileId),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: photos.isNotEmpty ? photos.length : 1,
              onPageChanged: (index) => setState(() => _currentPhotoIndex = index),
              itemBuilder: (context, index) {
                final url = photos.isNotEmpty
                    ? photos[index]
                    : "https://via.placeholder.com/400x400?text=No+Photo";
                return Image.network(url, fit: BoxFit.cover);
              },
            ),

            // Ombre portée pour garantir la lisibilité du texte
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent, Colors.black87],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Zones cliquables pour naviguer dans les photos
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

            Positioned(
              bottom: 24,
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
                    ),
                  ),
                  if (photos.length > 1) ...[
                    const SizedBox(height: 16),
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
                            color: _currentPhotoIndex == index
                                ? primaryColor
                                : Colors.white.withOpacity(0.5),
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