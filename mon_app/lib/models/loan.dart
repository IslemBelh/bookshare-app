class Loan {
  final String id;
  final String bookId;
  final String bookTitle;
  final String userId;
  final String userName;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final LoanStatus status;

  Loan({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    required this.userName,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
  });

  // Calculer si l'emprunt est en retard
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status == LoanStatus.borrowed;
  }

  // Jours restants avant la date de retour
  int get daysRemaining {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  factory Loan.fromMap(Map<String, dynamic> data) {
    return Loan(
      id: data['id'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      borrowDate: DateTime.parse(data['borrowDate']),
      dueDate: DateTime.parse(data['dueDate']),
      returnDate: data['returnDate'] != null ? DateTime.parse(data['returnDate']) : null,
      status: LoanStatus.values.firstWhere(
            (e) => e.toString() == 'LoanStatus.${data['status']}',
        orElse: () => LoanStatus.borrowed,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'userId': userId,
      'userName': userName,
      'borrowDate': borrowDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'status': status.name,
    };
  }
}

enum LoanStatus {
  borrowed('Emprunté'),
  returned('Retourné'),
  overdue('En retard');

  const LoanStatus(this.label);
  final String label;
}