import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Models/DonationCardModel.dart';
import '../../../Utils/Icons.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late final SupabaseClient supabase;

  @override
  void initState() {
    supabase = Supabase.instance.client;
    super.initState();
  }

  Future<({List<DonationCardModel> cards, double? collecteActuelle})> _load() async {
    final rows = await supabase
        .from('donation_cards')
        .select()
        .order('sort_order', ascending: true);

    final cards = (rows as List)
        .map((e) => DonationCardModel.fromMap(e as Map<String, dynamic>))
        .toList();

    double? collecteActuelle;
    try {
      final stat = await supabase
          .from('donations_stats')
          .select('dons_collectes')
          .order('updated_at', ascending: false)
          .limit(1)
          .single();
      collecteActuelle = (stat['dons_collectes'] as num).toDouble();
    } catch (_) {/* Ignore si erreur */}

    return (cards: cards, collecteActuelle: collecteActuelle);
  }

  @override
  Widget build(BuildContext context) {
    // Récupération de la couleur principale du thème pour l'adapter au mode sombre/clair
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // --- STYLE APPBAR MODIFIÉ ---
      appBar: AppBar(
        title: const Text(
          'Soutenir Amikone ❤️',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<({List<DonationCardModel> cards, double? collecteActuelle})>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          final cards = snap.data!.cards;
          final collecteActuelle = snap.data!.collecteActuelle;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in cards) ...[
                  _buildCard(context, c, collecteActuelle, primaryColor),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, DonationCardModel c, double? collecteActuelle, Color primaryColor) {
    switch (c.kind) {
      case 'info':
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconFromName(c.icon), color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        c.title ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if ((c.body ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    c.body!,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5, // Interligne plus aéré
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ],
            ),
          ),
        );

      case 'progress':
        final objectif = c.objectif ?? 0.0;
        final actuel = c.actuel ?? collecteActuelle ?? 0.0;
        final progression = objectif > 0 ? (actuel / objectif).clamp(0, 1).toDouble() : 0.0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconFromName(c.icon), color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        c.title ?? 'Objectif',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Collectés',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                        ),
                        Text(
                          '${actuel.toStringAsFixed(0)} €',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                    Text(
                      'Objectif : ${objectif.toStringAsFixed(0)} €',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progression,
                    backgroundColor: primaryColor.withOpacity(0.15), // Mieux adapté au mode sombre
                    color: primaryColor,
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'cta':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              final url = c.buttonUrl;
              if (url == null || url.isEmpty) return;

              if (url == 'action_stripe_checkout') {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Préparation de la page de don... ⏳')),
                  );

                  final res = await supabase.functions.invoke(
                    'stripe-checkout',
                  );

                  final responseData = res.data;
                  if (responseData != null && responseData['url'] != null) {
                    final stripeUri = Uri.parse(responseData['url']);

                    if (await canLaunchUrl(stripeUri)) {
                      await launchUrl(stripeUri, mode: LaunchMode.externalApplication);
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur de connexion : $e')),
                  );
                }
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirection... 💜')),
              );
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: Icon(iconFromName(c.icon), color: Colors.white),
            label: Text(
              c.buttonLabel ?? 'Soutenir',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}