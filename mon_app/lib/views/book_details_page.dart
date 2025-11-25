import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../providers/loans_provider.dart';
import '../providers/auth_provider.dart'; // ⭐ IMPORT AJOUTÉ
import '../models/loan.dart';

class BookDetailsPage extends StatelessWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du livre'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture (placeholder)
            Center(
              child: Container(
                width: 150,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.book, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Auteur
            Text(
              'Par ${book.author}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Disponibilité
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: book.isAvailable ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                book.isAvailable ? 'Disponible' : 'Emprunté',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Genres
            const Text(
              'Genres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: book.genres.map((genre) {
                return Chip(
                  label: Text(genre),
                  backgroundColor: Colors.blue[50],
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Résumé
            if (book.summary != null) ...[
              const Text(
                'Résumé',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.summary!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],

            // Boutons d'action
            Consumer(
              builder: (context, ref, child) {
                final User? user = ref.watch(currentUserProvider); // ⭐ VRAI UTILISATEUR
                final loans = ref.watch(loansProvider);
                final userLoans = loans.where((loan) => loan.status == LoanStatus.borrowed).toList();
                final hasBorrowedThisBook = userLoans.any((loan) => loan.bookId == book.id);

                if (user == null) {
                  return const Text(
                    'Veuillez vous connecter pour emprunter',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                if (hasBorrowedThisBook) {
                  // Livre déjà emprunté par l'utilisateur
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(loansProvider.notifier).returnBook(book.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${book.title}" retourné avec succès'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Retourner ce livre',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vous avez déjà emprunté ce livre',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  );
                } else if (book.isAvailable) {
                  // Livre disponible à l'emprunt
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // ⭐ CORRECTION ICI - Utilise le vrai userId
                        ref.read(loansProvider.notifier).borrowBook(
                          bookId: book.id,
                          bookTitle: book.title,
                          userId: user.uid, // ⭐ VRAI USER ID
                          userName: user.displayName ?? 'Utilisateur', // ⭐ VRAI NOM
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"${book.title}" emprunté avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Emprunter ce livre',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                } else {
                  // Livre indisponible
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Réservation de "${book.title}" demandée'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Réserver ce livre',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}