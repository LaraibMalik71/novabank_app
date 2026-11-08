import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'transactions_screen.dart';
import 'transaction_details_screen.dart';
import 'add_money_screen.dart';
import 'transfer_screen.dart';
import 'send_money_screen.dart';
import 'profile_screen.dart';
import 'pay_bills_screen.dart';
import 'recharge_screen.dart';
import '../services/notification_service.dart';
import 'notifications_screen.dart';
import '../providers/auth_provider.dart';

import 'package:flutter/services.dart';

import '../providers/card_provider.dart';
import 'my_cards_screen.dart';
import 'card_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showBalance = true;
  bool _showAccountNumber = false;
  int _selectedIndex = 0;
  String _formatAccountNumber(String number) {
    return number
        .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
        .trim();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TransactionProvider>().loadTransactions();
      NotificationService.instance.refreshUnreadCount();

      final user = context.read<AuthProvider>().currentUser;

      if (user != null) {
        context.read<CardProvider>().loadCards(
          userId: user['id'] as int,
          cardholderName: user['name'] as String,
        );
      }
    });
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        if (title == 'Add Money') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMoneyScreen()),
          );
        } else if (title == 'Send Money') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SendMoneyScreen()),
          );
        } else if (title == 'Transfer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransferScreen()),
          );
        } else if (title == 'Pay Bills') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PayBillsScreen()),
          );
        } else if (title == 'Recharge') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RechargeScreen()),
          );
        } else {
          _showComingSoon(title);
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isCredit = transaction.isCredit;

    final icon = isCredit
        ? Icons.call_received_rounded
        : Icons.call_made_rounded;

    final amountColor = isCredit ? AppColors.success : AppColors.textPrimary;

    final date =
        '${transaction.date.day.toString().padLeft(2, '0')}/'
        '${transaction.date.month.toString().padLeft(2, '0')}/'
        '${transaction.date.year}';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailsScreen(transaction: transaction),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.primary, size: 23),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isCredit
                        ? 'From: ${transaction.sender}'
                        : 'To: ${transaction.receiver}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'} Rs. '
                  '${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final authProvider = context.watch<AuthProvider>();
    final cardProvider = context.watch<CardProvider>();
    final accountNumber =
        authProvider.currentUser?['account_number'] as String? ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Welcome to NovaBank',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: NotificationService.instance.unreadCount,
                    builder: (context, unreadCount, child) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.primary,
                              size: 27,
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 9,
                              top: 8,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF244D70)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Total Account Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showBalance = !_showBalance;
                            });
                          },
                          icon: Icon(
                            _showBalance
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showBalance
                          ? 'Rs. ${transactionProvider.balance.toStringAsFixed(2)}'
                          : 'Rs. ••••••••',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: accountNumber.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _showAccountNumber = !_showAccountNumber;
                              });
                            },
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.credit_card_rounded,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'NovaBank Account',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          if (accountNumber.isEmpty)
                            const Text(
                              'Unavailable',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            )
                          else ...[
                            Flexible(
                              child: Text(
                                _showAccountNumber
                                    ? _formatAccountNumber(accountNumber)
                                    : '•••• ${accountNumber.substring(accountNumber.length - 4)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (_showAccountNumber)
                              IconButton(
                                tooltip: 'Copy account number',
                                visualDensity: VisualDensity.compact,
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: _formatAccountNumber(accountNumber),
                                    ),
                                  );

                                  if (!mounted) return;

                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Account number copied.'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              )
                            else
                              const Icon(
                                Icons.visibility_outlined,
                                color: Colors.white70,
                                size: 18,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Quick actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                alignment: WrapAlignment.start,
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildQuickAction(
                    icon: Icons.send_rounded,
                    title: 'Send Money',
                    color: AppColors.secondary,
                  ),
                  _buildQuickAction(
                    icon: Icons.receipt_long_outlined,
                    title: 'Pay Bills',
                    color: Colors.orange,
                  ),
                  _buildQuickAction(
                    icon: Icons.phone_android_rounded,
                    title: 'Recharge',
                    color: Colors.blue,
                  ),
                  _buildQuickAction(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Transfer',
                    color: Colors.purple,
                  ),
                  _buildQuickAction(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Add Money',
                    color: AppColors.success,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Card overview
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Cards',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyCardsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Manage',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              if (cardProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                )
              else if (cardProvider.cards.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'No cards available. Tap Manage to add a card.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CardDetailsScreen(card: cardProvider.cards.first),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(21),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 45,
                          width: 58,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.credit_card_rounded,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cardProvider.cards.first['nickname'] as String,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '•••• •••• •••• '
                                '${(cardProvider.cards.first['card_number'] as String).substring(12)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                cardProvider.cards.first['status'] as String,
                                style: TextStyle(
                                  color:
                                      cardProvider.cards.first['status'] ==
                                          'Active'
                                      ? AppColors.success
                                      : AppColors.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Recent transactions
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Transactions',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (transactionProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                )
              else if (transactionProvider.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else
                ...transactionProvider.transactions
                    .take(4)
                    .map(_buildTransactionItem),
            ],
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsScreen()),
            );
            return;
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            return;
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransferScreen()),
            );
            return;
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
