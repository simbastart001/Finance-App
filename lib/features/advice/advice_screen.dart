import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/transaction_provider.dart';
import '../../shared/widgets/custom_card.dart';

class AdviceScreen extends ConsumerWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionNotifier = ref.read(transactionProvider.notifier);
    final advice = _generateAdvice(transactionNotifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Advice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial Health Score
            CustomCard(
              color: _getHealthScoreColor(advice.healthScore),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getHealthScoreIcon(advice.healthScore),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Health Score',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${advice.healthScore}/100',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: advice.healthScore / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recommendations
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...advice.recommendations.map((recommendation) => CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _getRecommendationColor(recommendation.type).withOpacity(0.1),
                  child: Icon(
                    _getRecommendationIcon(recommendation.type),
                    color: _getRecommendationColor(recommendation.type),
                  ),
                ),
                title: Text(
                  recommendation.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(recommendation.description),
              ),
            )),

            const SizedBox(height: 24),

            // Financial Tips
            Text(
              'Financial Tips',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...advice.tips.map((tip) => CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(tip.description),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  FinancialAdvice _generateAdvice(TransactionNotifier notifier) {
    final totalIncome = notifier.getTotalIncome();
    final totalExpenses = notifier.getTotalExpenses();
    final balance = notifier.getBalance();
    final expenseTransactions = notifier.getExpenseTransactions();

    // Calculate health score
    int healthScore = 50; // Base score

    if (balance > 0) healthScore += 20;
    if (totalIncome > totalExpenses) healthScore += 15;
    if (totalExpenses < totalIncome * 0.8) healthScore += 15;

    final recommendations = <Recommendation>[];
    final tips = <FinancialTip>[];

    // Generate recommendations based on spending patterns
    if (balance < 0) {
      recommendations.add(Recommendation(
        type: RecommendationType.warning,
        title: 'Negative Balance Alert',
        description: 'Your expenses exceed your income. Consider reducing spending or increasing income.',
      ));
    }

    if (totalExpenses > totalIncome * 0.9) {
      recommendations.add(Recommendation(
        type: RecommendationType.caution,
        title: 'High Spending Ratio',
        description: 'You\'re spending 90%+ of your income. Try to save at least 10-20%.',
      ));
    }

    if (expenseTransactions.isNotEmpty) {
      final categorySpending = <String, double>{};
      for (final transaction in expenseTransactions) {
        categorySpending[transaction.category] = 
            (categorySpending[transaction.category] ?? 0) + transaction.amount;
      }

      final highestCategory = categorySpending.entries
          .reduce((a, b) => a.value > b.value ? a : b);

      if (highestCategory.value > totalExpenses * 0.4) {
        recommendations.add(Recommendation(
          type: RecommendationType.info,
          title: 'Category Focus: ${highestCategory.key}',
          description: 'This category represents ${(highestCategory.value / totalExpenses * 100).toStringAsFixed(1)}% of your spending.',
        ));
      }
    }

    // Add general tips
    tips.addAll([
      FinancialTip(
        title: '50/30/20 Rule',
        description: 'Allocate 50% for needs, 30% for wants, and 20% for savings and debt repayment.',
      ),
      FinancialTip(
        title: 'Emergency Fund',
        description: 'Build an emergency fund covering 3-6 months of expenses for financial security.',
      ),
      FinancialTip(
        title: 'Track Daily Expenses',
        description: 'Small daily expenses can add up. Track them to identify saving opportunities.',
      ),
      FinancialTip(
        title: 'Review Subscriptions',
        description: 'Regularly review and cancel unused subscriptions to reduce monthly expenses.',
      ),
    ]);

    return FinancialAdvice(
      healthScore: healthScore.clamp(0, 100),
      recommendations: recommendations,
      tips: tips,
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getHealthScoreIcon(int score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  Color _getRecommendationColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.warning:
        return Colors.red;
      case RecommendationType.caution:
        return Colors.orange;
      case RecommendationType.info:
        return Colors.blue;
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.warning:
        return Icons.warning;
      case RecommendationType.caution:
        return Icons.info;
      case RecommendationType.info:
        return Icons.lightbulb;
    }
  }
}

class FinancialAdvice {
  final int healthScore;
  final List<Recommendation> recommendations;
  final List<FinancialTip> tips;

  FinancialAdvice({
    required this.healthScore,
    required this.recommendations,
    required this.tips,
  });
}

class Recommendation {
  final RecommendationType type;
  final String title;
  final String description;

  Recommendation({
    required this.type,
    required this.title,
    required this.description,
  });
}

class FinancialTip {
  final String title;
  final String description;

  FinancialTip({
    required this.title,
    required this.description,
  });
}

enum RecommendationType { warning, caution, info }