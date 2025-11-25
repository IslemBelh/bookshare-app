import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer tous les livres
  Stream<List<Book>> getBooks() {
    print('🔄 Tentative de connexion à Firestore...');

    return _firestore
        .collection('books')
        .snapshots()
        .map((snapshot) {
      print('✅ Données reçues de Firestore: ${snapshot.docs.length} livres');
      return snapshot.docs
          .map((doc) {
        print('📖 Livre: ${doc.data()['title']}');
        return Book.fromFirestore(doc);
      })
          .toList();
    })
        .handleError((error) {
      print('❌ Erreur Firestore: $error');
      throw error;
    });
  }
}