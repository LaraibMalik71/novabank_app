import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/beneficiary_model.dart';
import '../providers/beneficiary_provider.dart';

class AddBeneficiaryScreen extends StatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  State<AddBeneficiaryScreen> createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _accountController = TextEditingController();

  String _beneficiaryType = 'bank';
  String? _selectedProvider;
  bool _isSaving = false;

  final List<String> _banks = [
    'National Bank of Pakistan',
    'HBL',
    'UBL',
    'MCB',
    'Allied Bank',
    'Bank Alfalah',
    'Meezan Bank',
  ];

  final List<String> _wallets = [
    'JazzCash',
    'Easypaisa',
    'SadaPay',
    'NayaPay',
    'UPaisa',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _saveBeneficiary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final beneficiary = BeneficiaryModel(
      name: _nameController.text.trim(),
      accountNumber: _accountController.text.trim(),
      bankName: _selectedProvider!,
      beneficiaryType: _beneficiaryType,
      createdAt: DateTime.now(),
    );

    final success = await context.read<BeneficiaryProvider>().addBeneficiary(
      beneficiary,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beneficiary saved successfully!')),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<BeneficiaryProvider>().errorMessage ??
                'Unable to save beneficiary.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = _beneficiaryType == 'bank' ? _banks : _wallets;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Beneficiary')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save Recipient',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save recipient details to make future payments easier.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Beneficiary Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),

                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'bank',
                      label: Text('Bank Account'),
                      icon: Icon(Icons.account_balance),
                    ),
                    ButtonSegment(
                      value: 'wallet',
                      label: Text('Mobile Wallet'),
                      icon: Icon(Icons.account_balance_wallet),
                    ),
                  ],
                  selected: {_beneficiaryType},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _beneficiaryType = selection.first;
                      _selectedProvider = null;
                      _accountController.clear();
                    });
                  },
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Name',
                    hintText: 'Enter recipient name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter recipient name.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  initialValue: _selectedProvider,
                  decoration: InputDecoration(
                    labelText: _beneficiaryType == 'bank'
                        ? 'Select Bank'
                        : 'Select Wallet',
                    prefixIcon: Icon(
                      _beneficiaryType == 'bank'
                          ? Icons.account_balance
                          : Icons.wallet,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  items: providers.map((provider) {
                    return DropdownMenuItem(
                      value: provider,
                      child: Text(provider),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProvider = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a provider.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _accountController,
                  keyboardType: TextInputType.number,
                  maxLength: _beneficiaryType == 'bank' ? 24 : 11,
                  decoration: InputDecoration(
                    labelText: _beneficiaryType == 'bank'
                        ? 'Account Number'
                        : 'Mobile Number',
                    hintText: _beneficiaryType == 'bank'
                        ? 'Enter account number'
                        : '03XXXXXXXXX',
                    prefixIcon: const Icon(Icons.numbers),
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: (value) {
                    final input = value?.trim() ?? '';

                    if (input.isEmpty) {
                      return _beneficiaryType == 'bank'
                          ? 'Please enter account number.'
                          : 'Please enter mobile number.';
                    }

                    if (_beneficiaryType == 'bank' && input.length < 6) {
                      return 'Account number must have at least 6 digits.';
                    }

                    if (_beneficiaryType == 'wallet' &&
                        !RegExp(r'^03\d{9}$').hasMatch(input)) {
                      return 'Enter a valid 11-digit mobile number.';
                    }

                    if (!RegExp(r'^\d+$').hasMatch(input)) {
                      return 'Only digits are allowed.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveBeneficiary,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Beneficiary'),
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
