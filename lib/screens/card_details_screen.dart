import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../theme/app_colors.dart';

class CardDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> card;

  const CardDetailsScreen({super.key, required this.card});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  bool _showCardNumber = false;

  Future<void> _editNickname() async {
    final nickname = await showDialog<String>(
      context: context,
      builder: (_) => const _EditCardNicknameDialog(),
    );

    if (nickname == null || !mounted) return;

    final userId = context.read<AuthProvider>().currentUser?['id'] as int?;

    if (userId == null) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await context.read<CardProvider>().updateNickname(
        cardId: widget.card['id'] as int,
        userId: userId,
        nickname: nickname,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Card nickname updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to update card nickname.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleCardStatus() async {
    final currentStatus = widget.card['status'] as String;
    final newStatus = currentStatus == 'Active' ? 'Blocked' : 'Active';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$newStatus Card?'),
          content: Text(
            newStatus == 'Blocked'
                ? 'Are you sure you want to block this card?'
                : 'Do you want to activate this card again?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(newStatus),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final userId = context.read<AuthProvider>().currentUser?['id'] as int?;

    if (userId == null) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await context.read<CardProvider>().updateStatus(
        cardId: widget.card['id'] as int,
        userId: userId,
        status: newStatus,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Card $newStatus successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to update card status.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Card?'),
          content: const Text(
            'Are you sure you want to delete this card? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final userId = context.read<AuthProvider>().currentUser?['id'] as int?;

    if (userId == null) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await context.read<CardProvider>().deleteCard(
        cardId: widget.card['id'] as int,
        userId: userId,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Card deleted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to delete card.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatCardNumber(String number) {
    return number
        .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = context.watch<CardProvider>();

    final currentCard = cardProvider.cards.firstWhere(
      (card) => card['id'] == widget.card['id'],
      orElse: () => widget.card,
    );

    final cardNumber = currentCard['card_number'] as String;
    final status = currentCard['status'] as String;
    final nickname = currentCard['nickname'] as String;
    final cardholderName = currentCard['cardholder_name'] as String;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Card Details'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF244D70)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.credit_card_rounded,
                      color: AppColors.secondary,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'NovaBank',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  _showCardNumber
                      ? _formatCardNumber(cardNumber)
                      : '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CARDHOLDER',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            cardholderName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _showCardNumber
                          ? 'Hide card number'
                          : 'Reveal card number',
                      onPressed: () {
                        setState(() {
                          _showCardNumber = !_showCardNumber;
                        });
                      },
                      icon: Icon(
                        _showCardNumber
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white,
                      ),
                    ),
                    if (_showCardNumber)
                      IconButton(
                        tooltip: 'Copy card number',
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);

                          await Clipboard.setData(
                            ClipboardData(text: cardNumber),
                          );

                          if (!mounted) return;

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Card number copied.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _detailRow('Card Nickname', nickname),
                const Divider(height: 25),
                _detailRow('Card Type', 'Debit'),
                const Divider(height: 25),
                _detailRow('Status', status),
                const Divider(height: 25),
                _detailRow(
                  'Card Number',
                  'Ending ${cardNumber.substring(cardNumber.length - 4)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          OutlinedButton.icon(
            onPressed: _editNickname,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Card Nickname'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _toggleCardStatus,
            icon: Icon(
              status == 'Active'
                  ? Icons.lock_outline_rounded
                  : Icons.lock_open_rounded,
            ),
            label: Text(status == 'Active' ? 'Block Card' : 'Unblock Card'),
            style: OutlinedButton.styleFrom(
              foregroundColor: status == 'Active'
                  ? AppColors.danger
                  : AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _deleteCard,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete Card'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditCardNicknameDialog extends StatefulWidget {
  const _EditCardNicknameDialog();

  @override
  State<_EditCardNicknameDialog> createState() =>
      _EditCardNicknameDialogState();
}

class _EditCardNicknameDialogState extends State<_EditCardNicknameDialog> {
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
      title: const Text('Edit Card Nickname'),
      content: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.words,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Card nickname',
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

            if (nickname.isNotEmpty) {
              Navigator.pop(context, nickname);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
