// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ProfilePage.dart';
import 'ProfileSetup.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<bool> _isProfileComplete() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return false;

    final res = await Supabase.instance.client
        .from('profiles')
        .select('birth_date')
        .eq('id', userId)
        .maybeSingle();

    if (res == null) {
      await Supabase.instance.client
          .from('profiles')
          .insert({
        'id': userId,
        'username': Supabase.instance.client.auth.currentUser!.email,
        'created_at': DateTime.now().toIso8601String(),
      });
      return false;
    }
    return res['birth_date'] != null;
  }

  Future<void> _goToSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
    );
    setState(() {}); // Rafraîchir à chaque retour du setup
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isProfileComplete(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final isComplete = snapshot.data!;
        if (isComplete) {
          return const ProfilePage();
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Ton profil n'est pas complet !\nComplète-le pour accéder à toutes les fonctionnalités.",
                    style: TextStyle(fontSize: 18), textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _goToSetup,
                    icon: const Icon(Icons.edit),
                    label: const Text("Compléter mon profil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}