import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart'; // ⭐ IMPORT AJOUTÉ

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  // ⭐ MÉTHODE DE REDIRECTION AJOUTÉE
  void _redirectToHome(BuildContext context) {
    if (mounted) {
      print("🔄 Redirection manuelle vers l'accueil...");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // Connexion
        print("🔄 Tentative de CONNEXION avec: ${_emailController.text.trim()}");
        await ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        print("✅ Connexion réussie!");

        // ⭐ REDIRECTION MANUELLE APRÈS CONNEXION
        _redirectToHome(context);
      } else {
        // Inscription
        print("🔄 Tentative d'INSCRIPTION avec: ${_emailController.text.trim()}");
        await ref.read(authNotifierProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _displayNameController.text.trim(),
        );
        print("✅ Inscription réussie!");

        // ⭐ REDIRECTION MANUELLE APRÈS INSCRIPTION
        _redirectToHome(context);
      }
    } catch (error) {
      // ⭐ DEBUG - Affiche l'erreur complète dans la console
      print("❌ ERREUR AUTH COMPLÈTE: $error");
      print("❌ TYPE D'ERREUR: ${error.runtimeType}");

      // Gestion des erreurs
      String errorMessage = "Une erreur s'est produite";

      if (error is FirebaseAuthException) {
        print("❌ CODE D'ERREUR: ${error.code}");
        print("❌ MESSAGE D'ERREUR: ${error.message}");

        switch (error.code) {
          case 'user-not-found':
            errorMessage = "Aucun utilisateur trouvé avec cet email";
            break;
          case 'wrong-password':
            errorMessage = "Mot de passe incorrect";
            break;
          case 'email-already-in-use':
            errorMessage = "Un compte existe déjà avec cet email";
            break;
          case 'weak-password':
            errorMessage = "Le mot de passe est trop faible";
            break;
          case 'invalid-email':
            errorMessage = "Adresse email invalide";
            break;
          default:
            errorMessage = error.message ?? "Erreur d'authentification";
        }
      } else {
        errorMessage = "Erreur inconnue: $error";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo et titre
              const Icon(
                Icons.library_books,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'BookShare',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Connectez-vous à votre compte' : 'Créez votre compte',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Champ nom d'affichage (seulement pour l'inscription)
              if (!_isLogin) ...[
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'affichage',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!_isLogin && (value == null || value.trim().isEmpty)) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Champ email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Bouton de connexion/inscription
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : Text(_isLogin ? 'Se connecter' : 'S\'inscrire'),
                ),
              ),
              const SizedBox(height: 16),

              // Lien pour basculer entre connexion/inscription
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _displayNameController.clear();
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Créer un nouveau compte'
                      : 'Déjà un compte ? Se connecter',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),

              // Lien mot de passe oublié
              if (_isLogin) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isLoading ? null : _showResetPasswordDialog,
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le mot de passe'),
        content: TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Entrez votre email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un email valide'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await ref.read(authNotifierProvider.notifier).resetPassword(email);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email de réinitialisation envoyé à $email'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${error.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}