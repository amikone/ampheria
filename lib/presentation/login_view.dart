import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ampheria/extensions/context_extension.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _onSuccess(dynamic response) {
    if (mounted) {
      updateUserLocation();
      updateUserActivity();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark background color
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  context.localizations.welcome,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.localizations.signInToContinue,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                SupaEmailAuth(
                  onSignInComplete: _onSuccess,
                  onSignUpComplete: (response) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.localizations.verifyEmail)),
                      );
                    }
                  },
                  metadataFields: [],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1, color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(context.localizations.or, style: const TextStyle(color: Colors.white70)),
                    ),
                    const Expanded(child: Divider(thickness: 1, color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 24),
                SupaSocialsAuth(
                  socialProviders: const [
                    OAuthProvider.google,
                    OAuthProvider.apple,
                  ],
                  onSuccess: _onSuccess,
                  onError: (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
                  },
                  redirectUrl: kIsWeb ? null : 'io.supabase.flutter://callback',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
