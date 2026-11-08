import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../services/transaction_service.dart';
import 'add_money_screen.dart';
import '../services/notification_service.dart';

class SendMoneyReviewScreen extends StatelessWidget {
  final String recipientName;
  final String mobileNumber;
  final String walletName;
  final double amount;
  final String description;

  const SendMoneyReviewScreen({
    super.key,
    required this.recipientName,
    required this.mobileNumber,
    required this.walletName,
    required this.amount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final availableBalance = context.watch<TransactionProvider>().balance;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Payment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFFE0F5F1),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 34,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirm Your Payment',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please review the payment details before proceeding.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Payment Amount',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'PKR ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 35),

                    _buildDetail('Recipient Name', recipientName),
                    _buildDetail('Mobile Number', mobileNumber),
                    _buildDetail('Wallet', walletName),
                    _buildDetail(
                      'Description',
                      description.trim().isEmpty
                          ? 'Not provided'
                          : description.trim(),
                    ),
                    _buildDetail('Payment Type', 'Mobile Wallet'),
                    _buildDetail('Currency', 'PKR'),
                    _buildDetail(
                      'Available Balance',
                      'PKR ${availableBalance.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<TransactionProvider>();

                    final transaction = TransactionModel(
                      title: 'Wallet Payment',
                      description: description.trim().isEmpty
                          ? 'Payment to $recipientName via $walletName'
                          : description.trim(),
                      amount: amount,
                      type: TransactionType.debit,
                      sender: 'My Account',
                      receiver: '$recipientName - $walletName ($mobileNumber)',
                      date: DateTime.now(),
                      status: TransactionStatus.pending,
                    );

                    // Step 1: Create Pending transaction.
                    final transactionId = await provider
                        .createPendingTransaction(transaction);

                    if (!context.mounted) return;

                    if (transactionId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to process payment. Please try again.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Step 2: Show processing indicator.
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 20),
                            Expanded(child: Text('Processing your payment...')),
                          ],
                        ),
                      ),
                    );

                    await Future.delayed(const Duration(seconds: 1));

                    // Step 3: Check balance and complete payment.
                    final result = await provider
                        .completePendingDebitTransaction(
                          transactionId: transactionId,
                          status: TransactionStatus.successful,
                        );

                    // Insufficient balance: update the same transaction to Failed.
                    bool failedStatusUpdated = true;

                    if (result == TransferResult.insufficientBalance) {
                      failedStatusUpdated = await provider
                          .updateTransactionStatus(
                            transactionId: transactionId,
                            status: TransactionStatus.failed,
                          );
                    }

                    if (!context.mounted) return;

                    // Close processing dialog.
                    Navigator.pop(context);

                    if (result == TransferResult.success) {
                      await NotificationService.instance.showNotification(
                        title: 'Wallet Payment Successful',
                        body:
                            'Your payment of PKR ${amount.toStringAsFixed(2)} to $recipientName via $walletName has been recorded successfully.',
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment completed successfully!'),
                        ),
                      );

                      Navigator.pop(context);
                    } else if (result == TransferResult.insufficientBalance) {
                      if (!failedStatusUpdated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to update transaction status.',
                            ),
                          ),
                        );
                        return;
                      }

                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Insufficient Balance'),
                          content: const Text(
                            'Your payment has failed because you do not have enough balance. '
                            'Would you like to add money to your account?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddMoneyScreen(),
                                  ),
                                );
                              },
                              child: const Text('Add Money'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to complete payment. Please try again.',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Confirm Payment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cancel Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
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
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
