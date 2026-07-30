import 'package:ampheria/presentation/page/server_picker_page.dart';
import 'package:ampheria/services/supabase_manager.dart';
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

  void _openServerPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ServerPickerPage()),
    );
    if (result == true && mounted) {
      // Force refresh of the whole app or just the LoginPage to ensure Supabase client is updated
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final currentServer = SupabaseManager().currentConfig;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _openServerPicker,
            icon: const Icon(Icons.language, color: Colors.white70),
            label: Text(
              currentServer?.name ?? 'Serveur',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E2C),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 60,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.localizations.welcome,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.localizations.signInToContinue,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 8,
                    color: const Color(0xFF2A2A3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              textTheme: const TextTheme(
                                bodyMedium: TextStyle(color: Colors.white70),
                                labelLarge: TextStyle(color: Colors.white),
                              ),
                            ),
                            child: SupaEmailAuth(
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
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(child: Divider(thickness: 1, color: Colors.white24)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  context.localizations.or,
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                                ),
                              ),
                              const Expanded(child: Divider(thickness: 1, color: Colors.white24)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SupaSocialsAuth(
                            socialProviders: [
                              OAuthProvider.google,
                              if (!isAndroid) OAuthProvider.apple,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
