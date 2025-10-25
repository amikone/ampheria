import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ProfileDetailModal extends StatefulWidget {
  final String profileId;

  const ProfileDetailModal({super.key, required this.profileId});

  @override
  State<ProfileDetailModal> createState() => _ProfileDetailModalState();
}

class _ProfileDetailModalState extends State<ProfileDetailModal> {
  final supabase = Supabase.instance.client;
  int _currentPhotoIndex = 0;
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
          .select('*, user_preferences(*)')
          .eq('id', widget.profileId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Erreur fetch profile: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox(
            height: 300,
            child: Center(child: Text('Profil introuvable')),
          );
        }

        final profile = snapshot.data!;
        final photos = List<String>.from(profile['photos'] ?? []);
        final username = profile['username'] ?? 'Utilisateur';
        final fullName = profile['full_name'] ?? username;
        final gender = profile['gender'] ?? 'Autre';
        final bio = profile['bio'] ?? 'Aucune description';
        final city = profile['city'] ?? '';
        final birthDate = profile['birth_date'] != null
            ? DateFormat.yMMMMd().format(DateTime.parse(profile['birth_date']))
            : 'Non précisée';

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Nom et username
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),


                // Carousel photos
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: photos.isNotEmpty ? photos.length : 1,
                    onPageChanged: (index) => setState(() => _currentPhotoIndex = index),
                    itemBuilder: (context, index) {
                      final url = photos.isNotEmpty
                          ? photos[index]
                          : "https://via.placeholder.com/400x400?text=No+Photo";
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(url, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
                if (photos.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(photos.length, (index) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPhotoIndex == index ? Colors.blue : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 16),

                // Infos détaillées
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoTile('Genre', gender),
                    _infoTile('Naissance', birthDate),
                    if (city.isNotEmpty) _infoTile('Ville', city),
                  ],
                ),
                const SizedBox(height: 16),

                // Bio
                Text(bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),

                // Bouton fermer
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}
