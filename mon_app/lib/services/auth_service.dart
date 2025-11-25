import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion avec email/mot de passe
  Future<User?> signIn(String email, String password) async {
    try {
      print('🔄 Tentative de connexion: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Connexion réussie: ${result.user?.uid}');
      return result.user;
    } catch (e) {
      print('❌ Erreur connexion: $e');
      return null;
    }
  }

  // Inscription
  Future<User?> signUp(String email, String password, String displayName) async {
    try {
      print('🔄 Tentative d\'inscription: $email');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Inscription Auth réussie: ${result.user?.uid}');

      // Créer le profil utilisateur dans Firestore
      if (result.user != null) {
        print('🔄 Création du profil Firestore...');
        await _firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'email': email,
          'displayName': displayName,
          'joinDate': DateTime.now(),
          'isActive': true,
          'favoriteGenres': [],
        });
        print('✅ Profil Firestore créé');
      }

      return result.user;
    } catch (e) {
      print('❌ Erreur inscription: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    print('🔄 Déconnexion...');
    await _auth.signOut();
    print('✅ Déconnexion réussie');
  }

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream de l'état d'authentification
  Stream<User?> get authStateChanges {
    print('🔄 Surveillance des changements d\'auth...');
    return _auth.authStateChanges();
  }
}