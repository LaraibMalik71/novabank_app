import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/beneficiary_model.dart';
import '../providers/beneficiary_provider.dart';
import 'add_beneficiary_screen.dart';

class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BeneficiaryProvider>().loadBeneficiaries();
      }
    });
  }

  String _maskAccountNumber(String number) {
    if (number.length <= 4) {
      return number;
    }

    return '${'*' * (number.length - 4)}${number.substring(number.length - 4)}';
  }

  Future<void> _openAddBeneficiary() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBeneficiaryScreen()),
    );

    if (mounted) {
      await context.read<BeneficiaryProvider>().loadBeneficiaries();
    }
  }

  Future<void> _confirmDelete(BeneficiaryModel beneficiary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Beneficiary?'),
          content: Text(
            'Are you sure you want to remove ${beneficiary.name} '
            'from your saved beneficiaries?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && beneficiary.id != null && mounted) {
      await context.read<BeneficiaryProvider>().deleteBeneficiary(
        beneficiary.id!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beneficiary removed successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beneficiaries')),
      body: Consumer<BeneficiaryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.beneficiaries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.loadBeneficiaries,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.beneficiaries.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: provider.loadBeneficiaries,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Saved Recipients',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage the people you frequently send money to.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 20),

                ...provider.beneficiaries.map(
                  (beneficiary) => _buildBeneficiaryCard(beneficiary),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBeneficiary,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Beneficiary'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Beneficiaries Yet',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your frequently used bank accounts or mobile wallets '
              'to make future payments easier.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiaryCard(BeneficiaryModel beneficiary) {
    final isBank = beneficiary.beneficiaryType == 'bank';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary
              .withValues(alpha: 0.1),
          child: Icon(
            isBank ? Icons.account_balance : Icons.wallet,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          beneficiary.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(beneficiary.bankName),
              const SizedBox(height: 3),
              Text(
                _maskAccountNumber(beneficiary.accountNumber),
                style: const TextStyle(letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                isBank ? 'Bank Account' : 'Mobile Wallet',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          onPressed: () => _confirmDelete(beneficiary),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Remove beneficiary',
        ),
      ),
    );
  }
}
