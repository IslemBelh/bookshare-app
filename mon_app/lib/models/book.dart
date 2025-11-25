import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String? isbn;
  final String? coverUrl;
  final String? summary;
  final List<String> genres;
  final bool isAvailable;
  final DateTime? addedDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
    this.summary,
    this.genres = const [],
    this.isAvailable = true,
    this.addedDate,
  });

  // Convertir depuis Firestore
  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      isbn: data['isbn'],
      coverUrl: data['coverUrl'],
      summary: data['summary'],
      genres: List<String>.from(data['genres'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      addedDate: data['addedDate'] != null
          ? (data['addedDate'] as Timestamp).toDate()
          : null,
    );
  }

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'coverUrl': coverUrl,
      'summary': summary,
      'genres': genres,
      'isAvailable': isAvailable,
      'addedDate': addedDate != null ? Timestamp.fromDate(addedDate!) : null,
    };
  }

  // ⭐ NOUVELLE MÉTHODE : Emprunter le livre (devient indisponible)
  Book copyWithBorrowed() {
    return Book(
      id: id,
      title: title,
      author: author,
      isbn: isbn,
      coverUrl: coverUrl,
      summary: summary,
      genres: genres,
      isAvailable: false, // ⭐ Devenu indisponible
      addedDate: addedDate,
    );
  }

  // ⭐ NOUVELLE MÉTHODE : Retourner le livre (redevient disponible)
  Book copyWithReturned() {
    return Book(
      id: id,
      title: title,
      author: author,
      isbn: isbn,
      coverUrl: coverUrl,
      summary: summary,
      genres: genres,
      isAvailable: true, // ⭐ Redevenue disponible
      addedDate: addedDate,
    );
  }

  // ⭐ NOUVELLE MÉTHODE : Mettre à jour la disponibilité
  Book copyWith({bool? isAvailable}) {
    return Book(
      id: id,
      title: title,
      author: author,
      isbn: isbn,
      coverUrl: coverUrl,
      summary: summary,
      genres: genres,
      isAvailable: isAvailable ?? this.isAvailable,
      addedDate: addedDate,
    );
  }

  // Version simplifiée sans Firestore pour l'instant
  factory Book.fromMap(Map<String, dynamic> data) {
    return Book(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      isbn: data['isbn'],
      coverUrl: data['coverUrl'],
      summary: data['summary'],
      genres: List<String>.from(data['genres'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      addedDate: data['addedDate'] != null
          ? DateTime.parse(data['addedDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'coverUrl': coverUrl,
      'summary': summary,
      'genres': genres,
      'isAvailable': isAvailable,
      'addedDate': addedDate?.toIso8601String(),
    };
  }
}