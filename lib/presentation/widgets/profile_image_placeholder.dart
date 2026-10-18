import 'package:flutter/material.dart';

class ProfileImagePlaceholder extends StatelessWidget {
  final String? name;
  final double iconSize;
  final String? subtext;

  const ProfileImagePlaceholder({
    super.key,
    this.name,
    this.iconSize = 56,
    this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    final initial = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()[0].toUpperCase()
        : null;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E1E2C),
            Color(0xFF2A1B4E),
            Color(0xFF121212),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(iconSize * 0.35),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurpleAccent.withValues(alpha: 0.5),
                    Colors.pinkAccent.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.35),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: initial != null
                  ? Text(
                      initial,
                      style: TextStyle(
                        fontSize: iconSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.purpleAccent,
                            blurRadius: 12,
                          )
                        ],
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      size: iconSize,
                      color: Colors.white70,
                    ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    subtext ?? 'Aucune photo',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
