import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../services/notification_service.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool _isProcessing = false;

  final List<double> _suggestedAmounts = [1000, 5000, 10000, 20000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _confirmAddMoney() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text.trim());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Add Money'),
          content: Text(
            'Do you want to add PKR ${amount.toStringAsFixed(2)} '
            'to your account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final transaction = TransactionModel(
      title: 'Money Added',
      description: 'Money added to account',
      amount: amount,
      type: TransactionType.credit,
      sender: 'Add Money',
      receiver: 'My Account',
      date: DateTime.now(),
      status: TransactionStatus.successful,
    );

    final success = await context.read<TransactionProvider>().addTransaction(
      transaction,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      await NotificationService.instance.showNotification(
        title: 'Money Added Successfully',
        body:
            'PKR ${amount.toStringAsFixed(2)} has been added to your NovaBank balance.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Money added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to add money. Please try again.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Money'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Add Money to Your Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Enter the amount you want to add.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  'Enter Amount',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    prefixText: 'PKR ',
                    hintText: '0.00',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }

                    if (amount > 1000000) {
                      return 'Maximum amount is PKR 1,000,000';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 25),

                const Text(
                  'Quick Amount',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _suggestedAmounts.map((amount) {
                    return OutlinedButton(
                      onPressed: () => _selectAmount(amount),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('PKR ${amount.toStringAsFixed(0)}'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _confirmAddMoney,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
