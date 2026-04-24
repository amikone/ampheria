import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- CONSTANTES DU DESIGN SYSTEM ---
const Color _kBackgroundBlack = Color(0xFF121212);
const Color _kPrimaryAccent = Colors.deepPurpleAccent;
const Color _kDangerRed = Colors.redAccent;
final Color _kGlassBackground = Colors.white.withOpacity(0.05);
final Color _kGlassBorder = Colors.white.withOpacity(0.1);

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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Material( // Assure que le fond reste noir profond, même en modal
        color: _kBackgroundBlack,
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
      child: Center(
        child: CircularProgressIndicator(color: _kPrimaryAccent),
      ),
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
      color: _kBackgroundBlack,
      child: const Text(
        'Profil introuvable.',
        style: TextStyle(fontSize: 16, color: Colors.white70),
      ),
    );
  }
}

class _ProfileContentView extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ProfileContentView({required this.profile});

  // --- COMPOSANTS PRIVÉS (Design System) ---

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _kGlassBackground,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: _kGlassBorder, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: _kPrimaryAccent, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: _kPrimaryAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimaryAccent, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _kPrimaryAccent,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tags = List<String>.from(profile['tags'] ?? []);

    return Scaffold(
      backgroundColor: _kBackgroundBlack,
      body: CustomScrollView(
        slivers: [
          _SliverProfileHeader(profile: profile),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _ProfileDetailsCard(profile: profile),
                  const SizedBox(height: 20),

                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("À propos", Icons.person_outline_rounded),
                        Text(
                          profile['bio'] ?? 'Aucune description.',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Intérêts", Icons.favorite_outline_rounded),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: tags.map((tagName) => _buildGlassChip(tagName)).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      label: const Text(
                        'Fermer le profil',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGlassBackground,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Forme pilule
                          side: BorderSide(color: _kGlassBorder),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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

  const _ProfileDetailsCard({required this.profile});

  String _getDisplayGender(String? gender) {
    switch (gender) {
      case 'male': return 'Homme';
      case 'female': return 'Femme';
      case 'other': return 'Autre';
      default: return 'Non précisé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gender = _getDisplayGender(profile['gender'] as String?);
    final city = profile['city'] ?? 'Non précisée';
    final birthDate = profile['birth_date'] != null
        ? '${(DateTime.now().difference(DateTime.parse(profile['birth_date'])).inDays / 365).floor()} ans'
        : 'Âge inconnu';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        color: _kGlassBackground,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: _kGlassBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoColumn(icon: Icons.person_outline_rounded, value: gender),
          Container(width: 1, height: 40, color: Colors.white24),
          _InfoColumn(icon: Icons.cake_outlined, value: birthDate),
          if (city.isNotEmpty && city != 'Non précisée') ...[
            Container(width: 1, height: 40, color: Colors.white24),
            _InfoColumn(icon: Icons.location_on_outlined, value: city),
          ]
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoColumn({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _kPrimaryAccent, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white
          ),
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
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPhoto() {
    if (_currentPhotoIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
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
              backgroundColor: _kBackgroundBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: _kGlassBorder),
              ),
              title: Row(
                children: const [
                  Icon(Icons.flag_outlined, color: _kDangerRed),
                  SizedBox(width: 12),
                  Text('Signaler ce profil', style: TextStyle(color: Colors.white)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Veuillez indiquer la raison de votre signalement :',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: _kPrimaryAccent,
                    decoration: InputDecoration(
                      hintText: 'Faux profil, comportement...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black26, // Fond plein foncé selon contrainte
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none, // Pas de bordure au repos
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: _kPrimaryAccent, width: 1.5), // Bordure primary au focus
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kDangerRed.withOpacity(0.1),
                    foregroundColor: _kDangerRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Forme pilule
                      side: const BorderSide(color: _kDangerRed),
                    ),
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
                          SnackBar(
                            content: const Text('Le profil a été signalé.', style: TextStyle(color: Colors.white)),
                            backgroundColor: _kGlassBackground,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _kGlassBorder)),
                          ),
                        );
                      }
                    } catch (e) {
                      setStateDialog(() => isSubmitting = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur : $e', style: const TextStyle(color: Colors.white)),
                            backgroundColor: _kDangerRed.withOpacity(0.8),
                          ),
                        );
                      }
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: _kDangerRed, strokeWidth: 2),
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

    return SliverAppBar(
      expandedHeight: 450.0,
      backgroundColor: Colors.transparent, // Transparente selon contrainte
      elevation: 0, // Pas d'élévation selon contrainte
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      actions: [
        if (profileId != null)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1), // Légère touche premium
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
                    : "https://via.placeholder.com/400x400/121212/FFFFFF?text=Aucune+Photo";
                return Image.network(url, fit: BoxFit.cover);
              },
            ),

            // Dégradé Noir profond pour lier l'image au Scaffold
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent, _kBackgroundBlack],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Navigation invisible
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
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (photos.length > 1) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(photos.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentPhotoIndex == index ? 24 : 8,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _currentPhotoIndex == index
                                ? _kPrimaryAccent
                                : Colors.white30,
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