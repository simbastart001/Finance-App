import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/models/transaction.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/utils/app_utils.dart';
import '../expenses/add_transaction_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final transactionNotifier = ref.read(transactionProvider.notifier);

    final totalIncome = transactionNotifier.getTotalIncome();
    final totalExpenses = transactionNotifier.getTotalExpenses();
    final balance = transactionNotifier.getBalance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Money'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            CustomCard(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppUtils.formatCurrency(balance),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

            const SizedBox(height: 16),

            // Income & Expenses Row
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    color: Colors.green.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.green.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Income',
                              style: TextStyle(color: Colors.green.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppUtils.formatCurrency(totalIncome),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.3),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomCard(
                    color: Colors.red.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_down, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Expenses',
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppUtils.formatCurrency(totalExpenses),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: 0.3),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Transactions
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (transactions.isEmpty)
              CustomCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first transaction to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...transactions.take(5).map((transaction) => CustomCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == TransactionType.income
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      transaction.type == TransactionType.income
                          ? Icons.add
                          : Icons.remove,
                      color: transaction.type == TransactionType.income
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
                  title: Text(transaction.title),
                  subtitle: Text(
                    '${transaction.category} • ${AppUtils.formatDate(transaction.date)}',
                  ),
                  trailing: Text(
                    '${transaction.type == TransactionType.income ? '+' : '-'}${AppUtils.formatCurrency(transaction.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transaction.type == TransactionType.income
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}