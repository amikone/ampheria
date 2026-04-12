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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final res = await Supabase.instance.client
        .from('profiles')
        .select('birth_date, full_name, city, gender')
        .eq('id', user.id)
        .maybeSingle();

    if (res == null) {
      // Si le profil n'existe pas du tout, on l'initialise
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'username': user.email,
        'created_at': DateTime.now().toIso8601String(),
      });
      return false;
    }

    // Vérification stricte des champs obligatoires
    final isNameValid = res['full_name'] != null && (res['full_name'] as String).trim().isNotEmpty;
    final isGenderValid = res['gender'] != null && (res['gender'] as String).trim().isNotEmpty;
    final isDateValid = res['birth_date'] != null;
    final isCityValid = res['city'] != null && (res['city'] as String).trim().isNotEmpty;

    return isNameValid && isGenderValid && isDateValid && isCityValid;
  }

  Future<void> _goToSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
    );
    // On rafraîchit la page au retour pour relancer le FutureBuilder
    setState(() {});
  }

  // --- COMPOSANTS UI / DESIGN SYSTEM ---

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildIncompleteProfileView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _buildGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.manage_accounts_outlined,
                  color: Colors.deepPurpleAccent,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Profil Incomplet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Complétez votre profil pour débloquer toutes les fonctionnalités et faire de belles rencontres.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _goToSetup,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text(
                    "Compléter mon profil",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Forme Pilule
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fond principal
      body: FutureBuilder<bool>(
        future: _isProfileComplete(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent, // Accent loader
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Une erreur est survenue.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final isComplete = snapshot.data ?? false;

          if (isComplete) {
            // Si tout est bon, on affiche la vraie page de profil
            return const ProfilePage();
          } else {
            // Sinon, on invite au setup avec notre UI Premium
            return SafeArea(child: _buildIncompleteProfileView());
          }
        },
      ),
    );
  }
}