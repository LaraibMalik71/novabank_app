import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import 'add_money_screen.dart';
import '../services/transaction_service.dart';
import '../services/notification_service.dart';

class PayBillsReviewScreen extends StatefulWidget {
  final String billType;
  final String providerName;
  final String referenceNumber;
  final double amount;

  const PayBillsReviewScreen({
    super.key,
    required this.billType,
    required this.providerName,
    required this.referenceNumber,
    required this.amount,
  });

  @override
  State<PayBillsReviewScreen> createState() => _PayBillsReviewScreenState();
}

class _PayBillsReviewScreenState extends State<PayBillsReviewScreen> {
  bool _isProcessing = false;

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);

    final provider = context.read<TransactionProvider>();

    final transaction = TransactionModel(
      title: '${widget.billType} Bill Payment',
      description:
          '${widget.providerName} - Reference number: ${widget.referenceNumber}',
      amount: widget.amount,
      type: TransactionType.debit,
      sender: 'My Account',
      receiver: '${widget.providerName} (${widget.billType})',
      date: DateTime.now(),
      status: TransactionStatus.pending,
    );

    final transactionId = await provider.createPendingTransaction(transaction);

    if (!mounted) return;

    if (transactionId == null) {
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create bill payment.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Processing your bill payment...')),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    final result = await provider.completePendingDebitTransaction(
      transactionId: transactionId,
      status: TransactionStatus.successful,
    );

    if (!mounted) return;

    if (result == TransferResult.insufficientBalance) {
      await provider.updateTransactionStatus(
        transactionId: transactionId,
        status: TransactionStatus.failed,
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
    setState(() => _isProcessing = false);

    if (result == TransferResult.success) {
      await NotificationService.instance.showNotification(
        title: 'Bill Payment Successful',
        body:
            'Your ${widget.providerName} ${widget.billType} bill payment of PKR ${widget.amount.toStringAsFixed(2)} has been recorded successfully.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill payment successful!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } else if (result == TransferResult.insufficientBalance) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Insufficient Balance'),
          content: const Text(
            'Your account balance is insufficient for this payment. '
            'Would you like to add money?',
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
                  MaterialPageRoute(builder: (_) => const AddMoneyScreen()),
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
          content: Text('Unable to process bill payment.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<TransactionProvider>().balance;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Bill Payment')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetail('Bill Type', widget.billType),
              _buildDetail('Provider', widget.providerName),
              _buildDetail('Reference Number', widget.referenceNumber),
              _buildDetail('Amount', 'PKR ${widget.amount.toStringAsFixed(2)}'),
              const Divider(height: 32),
              _buildDetail(
                'Available Balance',
                'PKR ${balance.toStringAsFixed(2)}',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirm Payment'),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
