import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = [];
  double _balance = 0.0;

  bool _isLoading = false;
  String? _errorMessage;

  TransactionType? _selectedType;
  TransactionStatus? _selectedStatus;

  List<TransactionModel> get transactions => _transactions;
  double get balance => _balance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TransactionType? get selectedType => _selectedType;
  TransactionStatus? get selectedStatus => _selectedStatus;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _transactionService.getAllTransactions();
      _balance = await _transactionService.getAccountBalance();
    } catch (e) {
      _errorMessage = 'Unable to load transactions. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      await _transactionService.addTransaction(transaction);
      await loadTransactions();
      return true;
    } catch (e) {
      _errorMessage = 'Unable to save transaction.';
      notifyListeners();
      return false;
    }
  }

  // Complete a pending debit transaction.
  Future<TransferResult> completePendingDebitTransaction({
    required int transactionId,
    required TransactionStatus status,
  }) async {
    try {
      final result = await _transactionService.completePendingDebitTransaction(
        transactionId: transactionId,
        status: status,
      );

      await loadTransactions();

      return result;
    } catch (e) {
      _errorMessage = 'Unable to complete transaction.';
      notifyListeners();
      return TransferResult.invalidTransaction;
    }
  }

  // Create a Pending transaction and return its database ID.
  Future<int?> createPendingTransaction(TransactionModel transaction) async {
    if (transaction.status != TransactionStatus.pending ||
        transaction.amount <= 0) {
      return null;
    }

    try {
      final transactionId = await _transactionService.addTransaction(
        transaction,
      );

      await loadTransactions();

      return transactionId;
    } catch (e) {
      _errorMessage = 'Unable to create pending transaction.';
      notifyListeners();
      return null;
    }
  }

  // Update an existing transaction's status.
  Future<bool> updateTransactionStatus({
    required int transactionId,
    required TransactionStatus status,
  }) async {
    try {
      final updatedRows = await _transactionService.updateTransactionStatus(
        transactionId: transactionId,
        status: status,
      );

      if (updatedRows == 0) return false;

      await loadTransactions();

      return true;
    } catch (e) {
      _errorMessage = 'Unable to update transaction status.';
      notifyListeners();
      return false;
    }
  }

  Future<TransferResult> makeTransfer(TransactionModel transaction) async {
    try {
      final result = await _transactionService
          .addDebitTransactionIfBalanceSufficient(transaction);

      if (result == TransferResult.success) {
        await loadTransactions();
      }

      return result;
    } catch (e) {
      _errorMessage = 'Unable to process transfer.';
      notifyListeners();
      return TransferResult.invalidTransaction;
    }
  }

  void filterByType(TransactionType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void filterByStatus(TransactionStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _selectedType = null;
    _selectedStatus = null;
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((transaction) {
      final matchesType =
          _selectedType == null || transaction.type == _selectedType;

      final matchesStatus =
          _selectedStatus == null || transaction.status == _selectedStatus;

      return matchesType && matchesStatus;
    }).toList();
  }
}
