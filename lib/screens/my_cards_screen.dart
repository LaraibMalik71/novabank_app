import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../theme/app_colors.dart';
import 'card_details_screen.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  Future<void> _showAddCardDialog() async {
    final nickname = await showDialog<String>(
      context: context,
      builder: (_) => const _AddCardDialog(),
    );

    if (nickname == null || !mounted) return;

    final user = context.read<AuthProvider>().currentUser;

    if (user == null) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await context.read<CardProvider>().addCard(
        userId: user['id'] as int,
        cardholderName: user['name'] as String,
        nickname: nickname,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('New debit card added successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to add card. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildCard(Map<String, dynamic> card) {
    final cardNumber = card['card_number'] as String;
    final nickname = card['nickname'] as String;
    final status = card['status'] as String;
    final isPrimary = card['is_primary'] == 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CardDetailsScreen(card: card)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF244D70)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.credit_card_rounded,
                  color: AppColors.secondary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'NovaBank Debit Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Primary',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARD NICKNAME',
                        style: TextStyle(color: Colors.white60, fontSize: 9),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Active'
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.danger.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Active'
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cards'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          if (cardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          if (cardProvider.cards.isEmpty) {
            return const Center(
              child: Text(
                'No cards available.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'Manage your debit cards',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ...cardProvider.cards.map(_buildCard),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: _showAddCardDialog,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add New Card'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCardDialog extends StatefulWidget {
  const _AddCardDialog();

  @override
  State<_AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<_AddCardDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Card'),
      content: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Card nickname',
          hintText: 'e.g. My Shopping Card',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final nickname = _controller.text.trim();

            Navigator.pop(
              context,
              nickname.isEmpty ? 'My Debit Card' : nickname,
            );
          },
          child: const Text('Add Card'),
        ),
      ],
    );
  }
}
