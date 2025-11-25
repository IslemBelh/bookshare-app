import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider simple pour tester l'authentification
final simpleAuthProvider = StateProvider<bool>((ref) {
  return false; // false = déconnecté, true = connecté
});