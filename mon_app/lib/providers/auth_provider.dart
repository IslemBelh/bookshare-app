import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ⭐ Provider pour l'état d'authentification AVEC DÉBOGAGE
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) {
    print("🔄 authStateChanges - Utilisateur: ${user?.uid ?? 'null'}");
    print("🔄 authStateChanges - Email: ${user?.email ?? 'null'}");
    print("🔄 authStateChanges - DisplayName: ${user?.displayName ?? 'null'}");
    return user;
  });
});

// ⭐ Provider pour l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// ⭐ Provider pour savoir si l'utilisateur est connecté
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// ⭐ Notifier pour gérer les actions d'authentification
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  // Inscription avec email/mot de passe
  Future<void> signUp(String email, String password, String displayName) async {
    state = const AsyncValue.loading();
    try {
      print("🔄 Création d'utilisateur avec email: $email");
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le profil utilisateur
      print("🔄 Mise à jour du displayName: $displayName");
      await userCredential.user!.updateDisplayName(displayName);

      print("✅ Utilisateur créé et profil mis à jour!");
      state = const AsyncValue.data(null);
    } catch (error) {
      print("❌ Erreur lors de l'inscription: $error");
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  // Connexion avec email/mot de passe
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await FirebaseAuth.instance.signOut();
      state = const AsyncValue.data(null);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      state = const AsyncValue.data(null);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }
}

// ⭐ Provider pour le notifier d'authentification
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier();
});