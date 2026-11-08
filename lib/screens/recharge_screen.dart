import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'recharge_review_screen.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();

  final List<String> _networks = ['Jazz', 'Zong', 'Telenor', 'Ufone'];

  String? _selectedNetwork;

  @override
  void dispose() {
    _mobileController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _continueRecharge() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (_selectedNetwork == null || amount == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RechargeReviewScreen(
          network: _selectedNetwork!,
          mobileNumber: _mobileController.text.trim(),
          amount: amount,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mobile Recharge'),
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
                const Text(
                  'Recharge Your Mobile',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Top up your mobile balance quickly and easily.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                _buildLabel('Select Mobile Network'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedNetwork,
                  decoration: _inputDecoration(
                    hint: 'Choose mobile network',
                    icon: Icons.sim_card_outlined,
                  ),
                  items: _networks.map((network) {
                    return DropdownMenuItem(
                      value: network,
                      child: Text(network),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNetwork = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a mobile network';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Mobile Number'),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: _inputDecoration(
                    hint: '03XXXXXXXXX',
                    icon: Icons.phone_android_outlined,
                  ),
                  validator: (value) {
                    final number = value?.trim() ?? '';

                    if (!RegExp(r'^03\d{9}$').hasMatch(number)) {
                      return 'Enter a valid 11-digit mobile number';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),

                _buildLabel('Recharge Amount (PKR)'),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    hint: 'Enter recharge amount',
                    icon: Icons.currency_exchange,
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid recharge amount';
                    }

                    if (amount > 100000) {
                      return 'Maximum recharge amount is PKR 100,000';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _continueRecharge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
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
