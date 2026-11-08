import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'transfer_review_screen.dart';

import 'package:provider/provider.dart';

import '../models/beneficiary_model.dart';
import '../providers/beneficiary_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();

  final _accountController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedBank;
  int? _selectedBeneficiaryId;
  List<BeneficiaryModel> _bankBeneficiaries = [];

  final List<String> _banks = [
    'National Bank of Pakistan',
    'Habib Bank Limited',
    'United Bank Limited',
    'MCB Bank',
    'Allied Bank',
    'Bank Alfalah',
    'Meezan Bank',
  ];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await context.read<BeneficiaryProvider>().loadBeneficiaries();

      if (!mounted) return;

      setState(() {
        _bankBeneficiaries = context
            .read<BeneficiaryProvider>()
            .beneficiaries
            .where((beneficiary) => beneficiary.beneficiaryType == 'bank')
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _continueTransfer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBank == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a bank.')));
      return;
    }

    final amount = double.parse(_amountController.text.trim());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferReviewScreen(
          recipientName: _nameController.text.trim(),
          accountNumber: _accountController.text.trim(),
          bankName: _selectedBank!,
          amount: amount,
          description: _descriptionController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bank Transfer'),
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
                  'Send Money',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the recipient details to make a bank transfer.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                if (_bankBeneficiaries.isNotEmpty) ...[
                  _buildLabel('Choose Saved Beneficiary'),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedBeneficiaryId,
                    decoration: _inputDecoration(
                      hint: 'Select a saved recipient',
                      icon: Icons.people_outline,
                    ),
                    items: _bankBeneficiaries.map((beneficiary) {
                      return DropdownMenuItem<int>(
                        value: beneficiary.id!,
                        child: Text(
                          '${beneficiary.name} • ${beneficiary.bankName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBeneficiaryId = value;

                        final selected = _bankBeneficiaries.firstWhere(
                          (beneficiary) => beneficiary.id == value,
                        );

                        _nameController.text = selected.name;
                        _accountController.text = selected.accountNumber;
                        _selectedBank = selected.bankName;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                _buildLabel('Recipient Account Number'),
                _buildTextField(
                  controller: _accountController,
                  hint: 'Enter account number',
                  icon: Icons.account_balance_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Account number is required';
                    }
                    if (value.trim().length < 6) {
                      return 'Enter a valid account number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Recipient Name'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Enter recipient name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Recipient name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Select Bank'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBank,
                  decoration: _inputDecoration(
                    hint: 'Choose recipient bank',
                    icon: Icons.account_balance,
                  ),
                  items: _banks.map((bank) {
                    return DropdownMenuItem(value: bank, child: Text(bank));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBank = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a bank';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Transfer Amount (PKR)'),
                _buildTextField(
                  controller: _amountController,
                  hint: 'Enter amount',
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
                const SizedBox(height: 20),

                _buildLabel('Description (Optional)'),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'What is this transfer for?',
                  icon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _continueTransfer,
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
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
