class Member {
  final String uid;
  final String email;
  final String displayName;
  final DateTime joinDate;
  final bool isActive;
  final List<String> favoriteGenres;

  Member({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.joinDate,
    this.isActive = true,
    this.favoriteGenres = const [],
  });

  // Version simplifiée sans Firestore pour l'instant
  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      joinDate: data['joinDate'] != null
          ? DateTime.parse(data['joinDate'])
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive,
      'favoriteGenres': favoriteGenres,
    };
  }
}