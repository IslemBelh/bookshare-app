import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // 📤 Uploader une image de couverture
  static Future<String> uploadBookCover(File imageFile, String bookId) async {
    try {
      final Reference ref = _storage.ref().child('book_covers/$bookId.jpg');
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur upload image: $e');
      rethrow;
    }
  }

  // 📥 Récupérer l'URL d'une image
  static Future<String> getBookCoverUrl(String bookId) async {
    try {
      return await _storage.ref().child('book_covers/$bookId.jpg').getDownloadURL();
    } catch (e) {
      print('Image non trouvée: $e');
      return ''; // Retourne une chaîne vide si pas d'image
    }
  }

  // 🗑️ Supprimer une image
  static Future<void> deleteBookCover(String bookId) async {
    try {
      await _storage.ref().child('book_covers/$bookId.jpg').delete();
    } catch (e) {
      print('Erreur suppression image: $e');
    }
  }
}