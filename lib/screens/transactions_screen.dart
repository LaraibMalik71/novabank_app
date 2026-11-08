import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import 'transaction_details_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(provider);
          }

          final transactions = provider.filteredTransactions;

          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: provider.loadTransactions,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSummary(provider),
                const SizedBox(height: 24),
                _buildTypeFilters(provider),
                const SizedBox(height: 16),
                _buildStatusFilter(provider),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${transactions.length} records',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (transactions.isEmpty)
                  _buildEmptyState()
                else
                  ...transactions.map(
                    (transaction) => _buildTransactionTile(transaction),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Transactions',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.transactions.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryItem(
                'Received',
                provider.transactions
                    .where((t) => t.isCredit)
                    .length
                    .toString(),
                Icons.arrow_downward,
              ),
              const SizedBox(width: 28),
              _summaryItem(
                'Sent',
                provider.transactions
                    .where((t) => !t.isCredit)
                    .length
                    .toString(),
                Icons.arrow_upward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 18),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeFilters(TransactionProvider provider) {
    final filters = [
      ('All', null),
      ('Received', TransactionType.credit),
      ('Sent', TransactionType.debit),
    ];

    return Row(
      children: filters.map((filter) {
        final isSelected = provider.selectedType == filter.$2;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => provider.filterByType(filter.$2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    filter.$1,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilter(TransactionProvider provider) {
    return DropdownButtonFormField<TransactionStatus?>(
      initialValue: provider.selectedStatus,
      decoration: InputDecoration(
        labelText: 'Filter by status',
        prefixIcon: const Icon(Icons.filter_list),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All statuses')),
        DropdownMenuItem(
          value: TransactionStatus.successful,
          child: Text('Successful'),
        ),
        DropdownMenuItem(
          value: TransactionStatus.pending,
          child: Text('Pending'),
        ),
        DropdownMenuItem(
          value: TransactionStatus.failed,
          child: Text('Failed'),
        ),
      ],
      onChanged: provider.filterByStatus,
    );
  }

  Widget _buildTransactionTile(TransactionModel transaction) {
    final isCredit = transaction.isCredit;

    final color = isCredit ? AppColors.success : AppColors.danger;

    final statusColor = switch (transaction.status) {
      TransactionStatus.successful => AppColors.success,
      TransactionStatus.pending => Colors.orange,
      TransactionStatus.failed => AppColors.danger,
    };

    final date =
        '${transaction.date.day.toString().padLeft(2, '0')}/'
        '${transaction.date.month.toString().padLeft(2, '0')}/'
        '${transaction.date.year}';

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionDetailsScreen(transaction: transaction),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),

        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCredit
                    ? 'From: ${transaction.sender}'
                    : 'To: ${transaction.receiver}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                transaction.status.name.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}Rs. ${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 55,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          const Text(
            'No transactions found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your transaction history will appear here.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TransactionProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 45),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: provider.loadTransactions,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
