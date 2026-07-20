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
      final rows = await supabase
          .from('likes')
          .select('''
          id, created_at,
          liker:profiles!likes_liker_id_fkey (
            id, username, full_name, photos, city
          )
        ''')
          .eq('liked_id', user.id)
          .order('created_at', ascending: false);
      final profiles = (rows as List)
          .map((r) => r['liker'] as Map<String, dynamic>?)
          .where((l) => l != null)
          .cast<Map<String, dynamic>>()
          .toList();

      return profiles;

    } catch (e) {
      debugPrint('Erreur fetch likes: $e');
      return [];
    }
  }

  Future<void> _rejectLike(String likerId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase
          .from('likes')
          .delete()
          .match({'liked_id': user.id, 'liker_id': likerId});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Like refusé')),
      );
      setState(() {
        _likesFuture = _fetchLikes(); // simple refetch
      });
    } catch (e) {
      debugPrint('Erreur delete like: $e');
    }
  }

  Future<void> _likeBack(String likedId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.functions.invoke('like-user', body: {'liked_id': likedId});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💖 Vous avez liké cette personne')),
      );
      setState(() {
        _likesFuture = _fetchLikes();
      });
    } catch (e) {
      debugPrint('Erreur like back: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Likes reçus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _likesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final likes = snapshot.data ?? [];
          if (likes.isEmpty) {
            return const Center(
              child: Text(
                "Aucun like pour le moment 😢",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: likes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final profile = likes[index];
                final photos = List<String>.from(profile['photos'] ?? []);
                final imageUrl = photos.isNotEmpty
                    ? photos[0]
                    : 'https://via.placeholder.com/400x400?text=No+Photo';
                final fullName =
                    profile['full_name'] ?? profile['username'] ?? 'Utilisateur';
                final city = profile['city'] ?? '';

                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E1E2C),
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: ProfileDetailModal(profileId: profile['id']),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              if (city.isNotEmpty)
                                Text(
                                  city,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _rejectLike(profile['id']),
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red,
                                      elevation: 2,
                                    ),
                                    child: const Icon(Icons.close),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _likeBack(profile['id']),
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                      backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                    ),
                                    child: const Icon(Icons.favorite),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
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