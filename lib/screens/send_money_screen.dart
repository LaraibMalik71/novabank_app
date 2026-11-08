import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'send_money_review_screen.dart';

import 'package:provider/provider.dart';

import '../models/beneficiary_model.dart';
import '../providers/beneficiary_provider.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedWallet;
  int? _selectedBeneficiaryId;
  List<BeneficiaryModel> _walletBeneficiaries = [];

  final List<String> _wallets = [
    'JazzCash',
    'Easypaisa',
    'SadaPay',
    'NayaPay',
    'UPaisa',
  ];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await context.read<BeneficiaryProvider>().loadBeneficiaries();

      if (!mounted) return;

      setState(() {
        _walletBeneficiaries = context
            .read<BeneficiaryProvider>()
            .beneficiaries
            .where((beneficiary) => beneficiary.beneficiaryType == 'wallet')
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _continuePayment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mobile wallet.')),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendMoneyReviewScreen(
          recipientName: _nameController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          walletName: _selectedWallet!,
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
        title: const Text('Send Money'),
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
                  'Mobile Wallet Transfer',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Send money to a mobile wallet in a few simple steps.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                if (_walletBeneficiaries.isNotEmpty) ...[
                  _buildLabel('Choose Saved Beneficiary'),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedBeneficiaryId,
                    decoration: _inputDecoration(
                      hint: 'Select a saved recipient',
                      icon: Icons.people_outline,
                    ),
                    items: _walletBeneficiaries.map((beneficiary) {
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

                        final selected = _walletBeneficiaries.firstWhere(
                          (beneficiary) => beneficiary.id == value,
                        );

                        _nameController.text = selected.name;
                        _mobileController.text = selected.accountNumber;
                        _selectedWallet = selected.bankName;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                _buildLabel('Select Mobile Wallet'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedWallet,
                  decoration: _inputDecoration(
                    hint: 'Choose mobile wallet',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  items: _wallets.map((wallet) {
                    return DropdownMenuItem(value: wallet, child: Text(wallet));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWallet = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a wallet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Recipient Mobile Number'),
                _buildTextField(
                  controller: _mobileController,
                  hint: '03XXXXXXXXX',
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mobile number is required';
                    }

                    final number = value.trim();

                    if (!RegExp(r'^03\d{9}$').hasMatch(number)) {
                      return 'Enter a valid 11-digit mobile number';
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

                _buildLabel('Amount (PKR)'),
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
                  hint: 'What is this payment for?',
                  icon: Icons.notes,
                  maxLines: 3,
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
