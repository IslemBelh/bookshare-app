import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/home_page.dart';
import 'views/login_page.dart';
import 'providers/auth_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐ UTILISE LE VRAI ÉTAT FIREBASE
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'BookShare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          // Si utilisateur connecté → Accueil, sinon → Login
          return user != null ? const HomePage() : const LoginPage();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) {
          print("Erreur auth: $error");
          return const LoginPage();
        },
      ),
    );
  }
}