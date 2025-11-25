import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationPreferences>((ref) {
  return NotificationNotifier();
});

class NotificationPreferences {
  final bool loanReminders;
  final bool newBooks;
  final bool communityUpdates;

  const NotificationPreferences({
    this.loanReminders = true,
    this.newBooks = true,
    this.communityUpdates = false,
  });

  NotificationPreferences copyWith({
    bool? loanReminders,
    bool? newBooks,
    bool? communityUpdates,
  }) {
    return NotificationPreferences(
      loanReminders: loanReminders ?? this.loanReminders,
      newBooks: newBooks ?? this.newBooks,
      communityUpdates: communityUpdates ?? this.communityUpdates,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationPreferences> {
  NotificationNotifier() : super(const NotificationPreferences());

  void toggleLoanReminders(bool enabled) {
    state = state.copyWith(loanReminders: enabled);

    if (enabled) {
      NotificationService.subscribeToTopic('loan_reminders');
      print('🔔 Rappels d\'emprunt activés');
    } else {
      NotificationService.unsubscribeFromTopic('loan_reminders');
      print('🔕 Rappels d\'emprunt désactivés');
    }
  }

  void toggleNewBooks(bool enabled) {
    state = state.copyWith(newBooks: enabled);

    if (enabled) {
      NotificationService.subscribeToTopic('new_books');
      print('🔔 Nouveaux livres activés');
    } else {
      NotificationService.unsubscribeFromTopic('new_books');
      print('🔕 Nouveaux livres désactivés');
    }
  }

  void toggleCommunityUpdates(bool enabled) {
    state = state.copyWith(communityUpdates: enabled);

    if (enabled) {
      NotificationService.subscribeToTopic('community_updates');
      print('🔔 Mises à jour communauté activées');
    } else {
      NotificationService.unsubscribeFromTopic('community_updates');
      print('🔕 Mises à jour communauté désactivées');
    }
  }

  void initializeTopics() {
    if (state.loanReminders) {
      NotificationService.subscribeToTopic('loan_reminders');
    }
    if (state.newBooks) {
      NotificationService.subscribeToTopic('new_books');
    }
    if (state.communityUpdates) {
      NotificationService.subscribeToTopic('community_updates');
    }
  }
}