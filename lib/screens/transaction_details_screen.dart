import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../theme/app_colors.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    final statusColor = switch (transaction.status) {
      TransactionStatus.successful => AppColors.success,
      TransactionStatus.pending => Colors.orange,
      TransactionStatus.failed => AppColors.danger,
    };

    final statusIcon = switch (transaction.status) {
      TransactionStatus.successful => Icons.check_circle,
      TransactionStatus.pending => Icons.access_time,
      TransactionStatus.failed => Icons.cancel,
    };

    final formattedDate =
        '${transaction.date.day.toString().padLeft(2, '0')}/'
        '${transaction.date.month.toString().padLeft(2, '0')}/'
        '${transaction.date.year}';

    final formattedTime =
        '${transaction.date.hour.toString().padLeft(2, '0')}:'
        '${transaction.date.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 34,
              backgroundColor: statusColor.withValues(alpha: 0.12),
              child: Icon(statusIcon, color: statusColor, size: 38),
            ),

            const SizedBox(height: 16),

            Text(
              '${isCredit ? '+' : '-'}Rs. '
              '${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isCredit ? AppColors.success : AppColors.textPrimary,
                fontSize: 29,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              transaction.status.name.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              transaction.title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Information',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _detailRow(
                    'Transaction ID',
                    transaction.id?.toString() ?? 'N/A',
                  ),

                  _detailRow(
                    'Transaction Type',
                    isCredit ? 'Money Received' : 'Money Sent',
                  ),

                  _detailRow('Date', formattedDate),

                  _detailRow('Time', formattedTime),

                  _detailRow('Sender', transaction.sender),

                  _detailRow('Receiver', transaction.receiver),

                  _detailRow(
                    'Status',
                    transaction.status.name.toUpperCase(),
                    valueColor: statusColor,
                  ),

                  _detailRow(
                    'Description',
                    transaction.description,
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Transactions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}
