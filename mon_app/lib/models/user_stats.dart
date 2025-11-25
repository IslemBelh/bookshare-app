class UserStats {
  final int totalLoans;
  final int currentLoans;
  final int returnedLoans;
  final int overdueLoans;
  final List<String> favoriteBooks;

  UserStats({
    required this.totalLoans,
    required this.currentLoans,
    required this.returnedLoans,
    required this.overdueLoans,
    required this.favoriteBooks,
  });

  // Pourcentage de livres retournés à temps
  double get onTimeReturnRate {
    if (totalLoans == 0) return 0.0;
    return ((returnedLoans - overdueLoans) / totalLoans) * 100;
  }

  // Moyenne d'emprunts par mois (estimation)
  double get averageLoansPerMonth {
    if (totalLoans == 0) return 0.0;
    // Supposons que l'utilisateur est membre depuis 6 mois
    return totalLoans / 6;
  }

  factory UserStats.empty() {
    return UserStats(
      totalLoans: 0,
      currentLoans: 0,
      returnedLoans: 0,
      overdueLoans: 0,
      favoriteBooks: [],
    );
  }
}