import 'package:flutter/material.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});


  final double objectif = 100.0;
  final double actuel = 36.5;

  double get progression => actuel / objectif;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soutenir Ampheria ❤️'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pourquoi demander un don ? 💡',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Ampheria est une application 100% gratuite. "
                  "Mais pour continuer à fonctionner, elle dépend d’un hébergement Supabase et d’autres services payants. "
                  "Vos dons permettent de garder l’app en ligne et de financer de nouvelles fonctionnalités.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 32),

            // ✅ Objectif visuel
            Text(
              'Objectif : ${objectif.toStringAsFixed(0)} €',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progression,
              backgroundColor: Colors.grey[300],
              color: Colors.deepPurple,
              minHeight: 14,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              '${actuel.toStringAsFixed(1)} € collectés',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 40),

            // ✅ Liste des limites actuelles Supabase
            const Text(
              'Limites actuelles de Supabase : 🚧',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const LimitItem(
              icon: Icons.storage,
              label: 'Stockage de fichiers : 1 Go gratuit',
            ),
            const LimitItem(
              icon: Icons.data_usage,
              label: 'Base de données : 500 Mo de données',
            ),
            const LimitItem(
              icon: Icons.speed,
              label: 'Requêtes : environ 500.000 / mois',
            ),
            const LimitItem(
              icon: Icons.cloud,
              label: 'Bande passante : 2 Go par mois',
            ),

            const Spacer(),

            // ✅ Bouton de don
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // 🔹 Plus tard tu pourras intégrer Stripe / PayPal ici
                  // Exemple : ouvrir un lien de don
                  const url = 'https://www.buymeacoffee.com/tonpseudo';
                  // ignore: deprecated_member_use
                  // launch(url);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Redirection vers la page de don 💜'),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite),
                label: const Text(
                  'Faire un don',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Petit widget de ligne pour les limites
class LimitItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const LimitItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
