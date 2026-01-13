import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/models/transaction.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/utils/app_utils.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final transactionNotifier = ref.read(transactionProvider.notifier);

    final expenses = transactionNotifier.getExpenseTransactions();
    final categoryData = _getCategoryData(expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Overview
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        'Income',
                        AppUtils.formatCurrency(transactionNotifier.getTotalIncome()),
                        Colors.green,
                        Icons.trending_up,
                      ),
                      _buildStatItem(
                        context,
                        'Expenses',
                        AppUtils.formatCurrency(transactionNotifier.getTotalExpenses()),
                        Colors.red,
                        Icons.trending_down,
                      ),
                      _buildStatItem(
                        context,
                        'Balance',
                        AppUtils.formatCurrency(transactionNotifier.getBalance()),
                        transactionNotifier.getBalance() >= 0 ? Colors.green : Colors.red,
                        Icons.account_balance_wallet,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Expense Categories Chart
            if (categoryData.isNotEmpty) ...[
              Text(
                'Expense Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: categoryData.entries.map((entry) {
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${(entry.value / transactionNotifier.getTotalExpenses() * 100).toStringAsFixed(1)}%',
                              color: _getCategoryColor(entry.key),
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: categoryData.entries.map((entry) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Recent Transactions Summary
            Text(
              'Transaction Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    'Total Transactions',
                    transactions.length.toString(),
                    Icons.receipt_long,
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    context,
                    'Income Transactions',
                    transactionNotifier.getIncomeTransactions().length.toString(),
                    Icons.add_circle_outline,
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    context,
                    'Expense Transactions',
                    transactionNotifier.getExpenseTransactions().length.toString(),
                    Icons.remove_circle_outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getCategoryData(List<Transaction> expenses) {
    final Map<String, double> categoryData = {};
    for (final expense in expenses) {
      categoryData[expense.category] = 
          (categoryData[expense.category] ?? 0) + expense.amount;
    }
    return categoryData;
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[category.hashCode % colors.length];
  }
}