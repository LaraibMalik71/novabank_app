import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'pay_bills_review_screen.dart';

class PayBillsScreen extends StatefulWidget {
  const PayBillsScreen({super.key});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();

  final List<String> _billTypes = ['Electricity', 'Gas', 'Water', 'Internet'];

  final Map<String, List<String>> _billProviders = {
    'Electricity': ['LESCO', 'K-Electric', 'IESCO', 'FESCO'],
    'Gas': ['SNGPL', 'SSGC'],
    'Water': ['WASA'],
    'Internet': ['PTCL', 'StormFiber', 'Nayatel'],
  };

  String? _selectedBillType;
  String? _selectedProvider;
  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _continuePayment() {
    if (_selectedBillType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bill type.')),
      );
      return;
    }

    if (_referenceController.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid reference number.')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PayBillsReviewScreen(
          billType: _selectedBillType!,
          providerName: _selectedProvider!,
          referenceNumber: _referenceController.text.trim(),
          amount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pay Bills'),
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
                  'Pay Your Bills',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pay your utility bills quickly and conveniently.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                _buildLabel('Select Bill Category'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBillType,
                  decoration: _inputDecoration(
                    hint: 'Choose bill category',
                    icon: Icons.receipt_long_outlined,
                  ),
                  items: _billTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBillType = value;
                      _selectedProvider = null;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a bill category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildLabel('Select Bill Provider'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedProvider,
                  decoration: _inputDecoration(
                    hint: 'Choose bill provider',
                    icon: Icons.business_outlined,
                  ),
                  items:
                      (_selectedBillType == null
                              ? <String>[]
                              : _billProviders[_selectedBillType] ?? <String>[])
                          .map((provider) {
                            return DropdownMenuItem(
                              value: provider,
                              child: Text(provider),
                            );
                          })
                          .toList(),
                  onChanged: _selectedBillType == null
                      ? null
                      : (value) {
                          setState(() {
                            _selectedProvider = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a bill provider';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Consumer / Reference Number'),
                _buildTextField(
                  controller: _referenceController,
                  hint: 'Enter consumer or reference number',
                  icon: Icons.numbers_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Reference number is required';
                    }
                    if (value.trim().length < 5) {
                      return 'Enter a valid reference number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Bill Amount (PKR)'),
                _buildTextField(
                  controller: _amountController,
                  hint: 'Enter bill amount',
                  icon: Icons.currency_exchange,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _continuePayment,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hint: hint, icon: icon),
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
}
