import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/loans_provider.dart';
import '../models/loan.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loans = ref.watch(loansProvider);
    final currentLoans = loans.where((loan) => loan.status == LoanStatus.borrowed).toList();
    final overdueLoans = loans.where((loan) => loan.isOverdue).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Emprunts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Section emprunts en retard
          if (overdueLoans.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${overdueLoans.length} emprunt(s) en retard',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Expanded(
            child: currentLoans.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun emprunt en cours',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les livres que vous empruntez apparaîtront ici',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: currentLoans.length,
              itemBuilder: (context, index) {
                final loan = currentLoans[index];
                return _buildLoanCard(loan, ref, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanCard(Loan loan, WidgetRef ref, BuildContext context) {
    final isOverdue = loan.isOverdue;
    final daysRemaining = loan.daysRemaining;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      color: isOverdue ? Colors.red[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loan.bookTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Emprunté le ${_formatDate(loan.borrowDate)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'À rendre le ${_formatDate(loan.dueDate)}',
              style: TextStyle(
                color: isOverdue ? Colors.red : Colors.grey,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 12),

            // Statut et actions
            Row(
              children: [
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isOverdue ? 'EN RETARD' : '${daysRemaining} JOURS RESTANTS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),

                // Bouton prolonger
                if (!isOverdue)
                  OutlinedButton(
                    onPressed: () {
                      ref.read(loansProvider.notifier).extendLoan(loan.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emprunt prolongé de 7 jours'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Prolonger'),
                  ),

                const SizedBox(width: 8),

                // Bouton retourner
                ElevatedButton(
                  onPressed: () {
                    ref.read(loansProvider.notifier).returnBook(loan.bookId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${loan.bookTitle}" retourné avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retourner'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}