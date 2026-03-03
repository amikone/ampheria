import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Récupération de la couleur principale pour s'adapter au thème (clair/sombre)
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Ajout d'une fine bordure en haut pour bien séparer la barre du contenu
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        // On rend le fond transparent pour utiliser celui du Container (adaptatif)
        backgroundColor: Colors.transparent,
        // Retire l'ombre tombante classique pour un style "flat"
        elevation: 0,
        // La couleur de la petite pilule derrière l'icône sélectionnée
        indicatorColor: primaryColor.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: primaryColor),
            label: 'People',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite, color: primaryColor),
            label: 'Like',
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: primaryColor),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: primaryColor),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: const Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism, color: primaryColor),
            label: 'Health',
          ),
        ],
      ),
    );
  }
}