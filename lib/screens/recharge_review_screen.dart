import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../services/transaction_service.dart';
import '../theme/app_colors.dart';
import 'add_money_screen.dart';
import '../services/notification_service.dart';

class RechargeReviewScreen extends StatefulWidget {
  final String network;
  final String mobileNumber;
  final double amount;

  const RechargeReviewScreen({
    super.key,
    required this.network,
    required this.mobileNumber,
    required this.amount,
  });

  @override
  State<RechargeReviewScreen> createState() => _RechargeReviewScreenState();
}

class _RechargeReviewScreenState extends State<RechargeReviewScreen> {
  bool _isProcessing = false;

  Future<void> _confirmRecharge() async {
    setState(() => _isProcessing = true);

    final provider = context.read<TransactionProvider>();

    final transaction = TransactionModel(
      title: 'Mobile Recharge',
      description: '${widget.network} recharge for ${widget.mobileNumber}',
      amount: widget.amount,
      type: TransactionType.debit,
      sender: 'My Account',
      receiver: '${widget.network} - ${widget.mobileNumber}',
      date: DateTime.now(),
      status: TransactionStatus.pending,
    );

    final transactionId = await provider.createPendingTransaction(transaction);

    if (!mounted) return;

    if (transactionId == null) {
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create mobile recharge.'),
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
            Expanded(child: Text('Processing your mobile recharge...')),
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
        title: 'Mobile Recharge Successful',
        body:
            'Your ${widget.network} recharge of PKR ${widget.amount.toStringAsFixed(2)} for ${widget.mobileNumber} has been recorded successfully.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile recharge successful!'),
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
            'Your account balance is insufficient for this recharge. '
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
          content: Text('Unable to process mobile recharge.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<TransactionProvider>().balance;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Recharge')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recharge Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetail('Mobile Network', widget.network),
              _buildDetail('Mobile Number', widget.mobileNumber),
              _buildDetail(
                'Recharge Amount',
                'PKR ${widget.amount.toStringAsFixed(2)}',
              ),
              const Divider(height: 32),
              _buildDetail(
                'Available Balance',
                'PKR ${balance.toStringAsFixed(2)}',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmRecharge,
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
                      : const Text('Confirm Recharge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
