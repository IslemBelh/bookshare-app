import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    print('🔄 Initialisation des notifications Firebase...');

    try {
      // Configuration basique - sans service Android
      await _configureBasicMessaging();
      await _getFCMToken();

      print('✅ Notifications Firebase initialisées avec succès');
    } catch (e) {
      print('❌ Erreur initialisation notifications: $e');
    }
  }

  static Future<void> _configureBasicMessaging() async {
    // Écouter seulement les messages en foreground (pas besoin de service)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Notification reçue en foreground:');
      print('   Titre: ${message.notification?.title}');
      print('   Corps: ${message.notification?.body}');
      print('   Données: ${message.data}');
    });

    // Écouter les messages quand l'app est en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Notification ouverte depuis background:');
      print('   Titre: ${message.notification?.title}');
      _handleNotificationClick(message);
    });

    // Demander les permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Statut permissions: ${settings.authorizationStatus}');
  }

  static Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('🔑 Token FCM: $token');

      // Écouter les changements de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 Nouveau token FCM: $newToken');
      });
    } catch (e) {
      print('❌ Erreur récupération token FCM: $e');
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    print('🎯 Notification cliquée:');
    print('   Type: ${data['type']}');
    print('   Livre: ${data['bookTitle']}');

    // Ici on pourrait naviguer vers une page spécifique
    if (data['type'] == 'loan_reminder') {
      print('📚 Redirection vers rappels d\'emprunt');
    } else if (data['type'] == 'new_book') {
      print('🆕 Redirection vers nouveau livre');
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Abonné au topic: $topic');
    } catch (e) {
      print('❌ Erreur abonnement topic $topic: $e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Désabonné du topic: $topic');
    } catch (e) {
      print('❌ Erreur désabonnement topic $topic: $e');
    }
  }
}