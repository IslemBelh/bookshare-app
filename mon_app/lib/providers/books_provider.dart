import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

// ⭐ Provider pour récupérer tous les livres depuis Firestore
final booksProvider = StreamProvider<List<Book>>((ref) {
  return FirebaseFirestore.instance
      .collection('books')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  });
});

// ⭐ Provider pour la recherche
final booksSearchProvider = StateProvider<String>((ref) => '');

// ⭐ Provider pour les livres filtrés (disponibles + recherche)
final filteredBooksProvider = Provider<List<Book>>((ref) {
  final booksAsync = ref.watch(booksProvider);
  final searchQuery = ref.watch(booksSearchProvider);

  return booksAsync.when(
    data: (books) {
      if (searchQuery.isEmpty) {
        // Afficher seulement les livres disponibles
        return books.where((book) => book.isAvailable).toList();
      }
      // Recherche dans le titre et l'auteur
      return books.where((book) =>
      book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    },
    loading: () => [],
    error: (error, stack) {
      print("❌ Erreur Firestore: $error");
      return [];
    },
  );
});