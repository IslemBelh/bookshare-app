import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats.dart';
import '../models/loan.dart'; // ⭐ IMPORT AJOUTÉ
import 'loans_provider.dart';

// ⭐ PROVIDER RÉACTIF POUR LES STATISTIQUES
final userStatsProvider = Provider.family<UserStats, String>((ref, userId) {
  final loans = ref.watch(loansProvider);

  print("📊 Recalcul des stats pour user: $userId - ${loans.length} emprunts totaux");

  final userLoans = loans.where((loan) => loan.userId == userId).toList();

  final totalLoans = userLoans.length;
  final currentLoans = userLoans.where((loan) => loan.status == LoanStatus.borrowed).length;
  final returnedLoans = userLoans.where((loan) => loan.status == LoanStatus.returned).length;
  final overdueLoans = userLoans.where((loan) => loan.isOverdue).length;

  // Livres les plus empruntés - CORRECTION SYNTAXE
  final bookCount = <String, int>{};
  for (final loan in userLoans) {
    bookCount[loan.bookTitle] = (bookCount[loan.bookTitle] ?? 0) + 1;
  }

  // CORRECTION : Utiliser une variable temporaire
  final bookEntries = bookCount.entries.toList();
  bookEntries.sort((a, b) => b.value.compareTo(a.value));
  final favoriteBooks = bookEntries.take(3).map((e) => e.key).toList();

  final stats = UserStats(
    totalLoans: totalLoans,
    currentLoans: currentLoans,
    returnedLoans: returnedLoans,
    overdueLoans: overdueLoans,
    favoriteBooks: favoriteBooks,
  );

  print("📈 Stats calculées - Total: $totalLoans, En cours: $currentLoans");

  return stats;
});

// ⭐ PROVIDER RÉACTIF POUR LES EMPRUNTS RÉCENTS
final recentLoansProvider = Provider.family<List<Loan>, String>((ref, userId) {
  final loans = ref.watch(loansProvider);

  final userLoans = loans
      .where((loan) => loan.userId == userId)
      .toList()
    ..sort((a, b) => b.borrowDate.compareTo(a.borrowDate));

  return userLoans.take(5).toList();
});