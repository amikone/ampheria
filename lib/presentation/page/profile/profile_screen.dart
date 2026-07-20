import 'package:ampheria/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ampheria/extensions/context_extension.dart';
import 'view/profile_page.dart';
import 'view/profile_setup.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _goToSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
    );
    setState(() {});
    ref.invalidate(profileCompletionProvider);
  }

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
              Text(
                context.localizations.incompleteProfileTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                context.localizations.incompleteProfileDesc,
                style: const TextStyle(
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
                  label: Text(
                    context.localizations.completeMyProfile,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
    final profileAsync = ref.watch(profileCompletionProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurpleAccent,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            context.localizations.genericError,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        data: (isComplete) {
          if (isComplete) {
            return const ProfilePage();
          } else {
            return SafeArea(child: _buildIncompleteProfileView());
          }
        },
      ),
    );
  }
}