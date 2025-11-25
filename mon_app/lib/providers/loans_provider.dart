import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan.dart';
import '../models/user_stats.dart';

final loansProvider = StateNotifierProvider<LoansNotifier, List<Loan>>((ref) {
  return LoansNotifier();
});

class LoansNotifier extends StateNotifier<List<Loan>> {
  LoansNotifier() : super([]);

  // Emprunter un livre
  void borrowBook({
    required String bookId,
    required String bookTitle,
    required String userId,
    required String userName,
  }) {
    final now = DateTime.now();
    final dueDate = DateTime.now().add(const Duration(days: 21)); // 3 semaines

    final newLoan = Loan(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      bookId: bookId,
      bookTitle: bookTitle,
      userId: userId,
      userName: userName,
      borrowDate: now,
      dueDate: dueDate,
      status: LoanStatus.borrowed,
    );

    state = [...state, newLoan];

    // ⭐ DEBUG AJOUTÉ
    print("📚 NOUVEL EMPRUNT CRÉÉ:");
    print("   👤 Utilisateur: $userName ($userId)");
    print("   📖 Livre: $bookTitle");
    print("   📊 Total emprunts dans le système: ${state.length}");
    print("   👤 Emprunts de cet utilisateur: ${state.where((loan) => loan.userId == userId).length}");
  }

  // Retourner un livre
  void returnBook(String bookId) {
    state = state.map((loan) {
      if (loan.bookId == bookId && loan.status == LoanStatus.borrowed) {
        return Loan(
          id: loan.id,
          bookId: loan.bookId,
          bookTitle: loan.bookTitle,
          userId: loan.userId,
          userName: loan.userName,
          borrowDate: loan.borrowDate,
          dueDate: loan.dueDate,
          returnDate: DateTime.now(),
          status: LoanStatus.returned,
        );
      }
      return loan;
    }).toList();
  }

  // Prolonger un emprunt
  void extendLoan(String loanId) {
    state = state.map((loan) {
      if (loan.id == loanId && loan.status == LoanStatus.borrowed) {
        return Loan(
          id: loan.id,
          bookId: loan.bookId,
          bookTitle: loan.bookTitle,
          userId: loan.userId,
          userName: loan.userName,
          borrowDate: loan.borrowDate,
          dueDate: loan.dueDate.add(const Duration(days: 7)), // +1 semaine
          returnDate: loan.returnDate,
          status: loan.status,
        );
      }
      return loan;
    }).toList();
  }

  // Récupérer les emprunts d'un utilisateur
  List<Loan> getUserLoans(String userId) {
    return state.where((loan) => loan.userId == userId).toList();
  }

  // Récupérer les emprunts en cours
  List<Loan> get currentLoans {
    return state.where((loan) => loan.status == LoanStatus.borrowed).toList();
  }

  // Récupérer les emprunts en retard
  List<Loan> get overdueLoans {
    return state.where((loan) => loan.isOverdue).toList();
  }

  // ⭐ NOUVELLES MÉTHODES POUR LES STATISTIQUES

  // Statistiques pour un utilisateur spécifique
  UserStats getUserStats(String userId) {
    final userLoans = state.where((loan) => loan.userId == userId).toList();

    final totalLoans = userLoans.length;
    final currentLoans = userLoans.where((loan) => loan.status == LoanStatus.borrowed).length;
    final returnedLoans = userLoans.where((loan) => loan.status == LoanStatus.returned).length;
    final overdueLoans = userLoans.where((loan) => loan.isOverdue).length;

    // Livres les plus empruntés
    final bookCount = <String, int>{};
    for (final loan in userLoans) {
      bookCount[loan.bookTitle] = (bookCount[loan.bookTitle] ?? 0) + 1;
    }

    // CORRECTION : Utiliser une variable temporaire pour le tri
    final bookEntries = bookCount.entries.toList();
    bookEntries.sort((a, b) => b.value.compareTo(a.value));
    final favoriteBooks = bookEntries.take(3).map((e) => e.key).toList();

    return UserStats(
      totalLoans: totalLoans,
      currentLoans: currentLoans,
      returnedLoans: returnedLoans,
      overdueLoans: overdueLoans,
      favoriteBooks: favoriteBooks,
    );
  }

  // Historique des emprunts récents
  List<Loan> getRecentLoans(String userId, {int limit = 5}) {
    // CORRECTION : Utiliser une variable temporaire pour le tri
    final userLoans = state.where((loan) => loan.userId == userId).toList();
    userLoans.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
    return userLoans.take(limit).toList();
  }

  // Récupérer les livres actuellement empruntés par un utilisateur
  List<Loan> getCurrentUserLoans(String userId) {
    return state
        .where((loan) => loan.userId == userId && loan.status == LoanStatus.borrowed)
        .toList();
  }

  // Vérifier si un utilisateur a déjà emprunté un livre spécifique
  bool hasUserBorrowedBook(String userId, String bookId) {
    return state.any((loan) =>
    loan.userId == userId &&
        loan.bookId == bookId &&
        loan.status == LoanStatus.borrowed
    );
  }

  // Obtenir le nombre total d'emprunts dans le système
  int get totalLoansCount => state.length;

  // Obtenir le nombre d'emprunts actifs
  int get activeLoansCount => state.where((loan) => loan.status == LoanStatus.borrowed).length;

  // Obtenir le taux de retour global
  double get globalReturnRate {
    if (state.isEmpty) return 0.0;
    final returnedCount = state.where((loan) => loan.status == LoanStatus.returned).length;
    return (returnedCount / state.length) * 100;
  }
}