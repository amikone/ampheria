import 'package:flutter/material.dart';

IconData iconFromName(String? name) {
  switch (name) {
    case 'lightbulb_outline':
      return Icons.lightbulb_outline;
    case 'track_changes':
      return Icons.track_changes;
    case 'favorite':
      return Icons.favorite;
    default:
      return Icons.info_outline;
  }
}