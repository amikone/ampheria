import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Widgets/ProfileDetailModal.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _likesFuture;

  @override
  void initState() {
    super.initState();
    _likesFuture = _fetchLikes();
  }

  Future<List<Map<String, dynamic>>> _fetchLikes() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await supabase
          .from('likes')
          .select('*, liker:liker_id (id, username, full_name, photos, city)')
          .eq('liked_id', user.id);

      if (response != null && response is List) {
        return response
            .map<Map<String, dynamic>>((like) => like['liker'] as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      debugPrint('Erreur fetch likes: $e');
    }
    return [];
  }

  Future<void> _likeBack(String likedId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.functions.invoke('like-user', body: {'liked_id': likedId});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💖 Vous avez liké cette personne')),
      );
      setState(() {
        _likesFuture = _fetchLikes(); // rafraîchir la liste
      });
    } catch (e) {
      debugPrint('Erreur like back: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💌 Likes reçus')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _likesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final likes = snapshot.data ?? [];
          if (likes.isEmpty) {
            return const Center(child: Text("Aucun like pour le moment 😢"));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: likes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cards par ligne
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75, // hauteur des cards
              ),
              itemBuilder: (context, index) {
                final profile = likes[index];
                final photos = List<String>.from(profile['photos'] ?? []);
                final imageUrl = photos.isNotEmpty
                    ? photos[0]
                    : 'https://via.placeholder.com/400x400?text=No+Photo';
                final fullName = profile['full_name'] ?? profile['username'] ?? 'Utilisateur';
                final city = profile['city'] ?? '';

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (city.isNotEmpty) Text(city, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _likeBack(profile['id']),
                                  child: const Icon(Icons.favorite, size: 16),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1E1E2C), // fond sombre ici
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: ProfileDetailModal(profileId: profile['id']),
                                      ),
                                    );
                                  },
                                  child: const Text("Voir plus"),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
