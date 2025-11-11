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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soutenir Amikone ❤️'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<({List<DonationCardModel> cards, double? collecteActuelle})>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          final cards = snap.data!.cards;
          final collecteActuelle = snap.data!.collecteActuelle;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in cards) ...[
                  _buildCard(context, c, collecteActuelle),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, DonationCardModel c, double? collecteActuelle) {
    switch (c.kind) {
      case 'info':
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(iconFromName(c.icon), color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.title ?? '',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if ((c.body ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    c.body!,
                    style: Theme.of(context).textTheme.bodyLarge,
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
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(iconFromName(c.icon), color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.title ?? 'Objectif',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Objectif : ${objectif.toStringAsFixed(0)} €',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progression,
                    backgroundColor: Colors.grey[300],
                    color: Colors.deepPurple,
                    minHeight: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${actuel.toStringAsFixed(1)} € collectés',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      case 'cta':
        return Center(
          child: ElevatedButton.icon(
            onPressed: () async {
              final url = c.buttonUrl;
              if (url == null || url.isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirection vers la page de don 💜')),
              );
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: Icon(iconFromName(c.icon), color: Colors.white),
            label: Text(
              c.buttonLabel ?? 'Soutenir',
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}