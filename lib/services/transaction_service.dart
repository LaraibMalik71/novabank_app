import '../models/transaction_model.dart';
import 'database_service.dart';

enum TransferResult { success, insufficientBalance, invalidTransaction }

class TransactionService {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Add a new transaction.
  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await _databaseService.database;

    final transactionMap = transaction.toMap();
    transactionMap.remove('id');

    return db.insert('transactions', transactionMap);
  }

  // Update the status of an existing transaction.
  Future<int> updateTransactionStatus({
    required int transactionId,
    required TransactionStatus status,
  }) async {
    final db = await _databaseService.database;

    return db.update(
      'transactions',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }

  // Complete a pending debit transaction safely.
  Future<TransferResult> completePendingDebitTransaction({
    required int transactionId,
    required TransactionStatus status,
  }) async {
    if (status != TransactionStatus.successful &&
        status != TransactionStatus.failed) {
      return TransferResult.invalidTransaction;
    }

    final db = await _databaseService.database;

    return db.transaction((txn) async {
      final records = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );

      if (records.isEmpty) {
        return TransferResult.invalidTransaction;
      }

      final record = records.first;

      if (record['type'] != TransactionType.debit.name ||
          record['status'] != TransactionStatus.pending.name) {
        return TransferResult.invalidTransaction;
      }

      final amount = (record['amount'] as num).toDouble();

      if (amount <= 0) {
        return TransferResult.invalidTransaction;
      }

      if (status == TransactionStatus.successful) {
        final result = await txn.rawQuery('''
        SELECT COALESCE(
          SUM(
            CASE
              WHEN type = 'credit' AND status = 'successful'
                THEN amount
              WHEN type = 'debit' AND status = 'successful'
                THEN -amount
              ELSE 0
            END
          ),
          0
        ) AS balance
        FROM transactions
      ''');

        final balance = (result.first['balance'] as num).toDouble();

        if (balance < amount) {
          return TransferResult.insufficientBalance;
        }
      }

      final updatedRows = await txn.update(
        'transactions',
        {'status': status.name},
        where: 'id = ? AND status = ?',
        whereArgs: [transactionId, TransactionStatus.pending.name],
      );

      return updatedRows == 1
          ? TransferResult.success
          : TransferResult.invalidTransaction;
    });
  }

  // Add a debit transaction only when sufficient balance is available.
  Future<TransferResult> addDebitTransactionIfBalanceSufficient(
    TransactionModel transaction,
  ) async {
    if (transaction.type != TransactionType.debit ||
        transaction.status != TransactionStatus.successful ||
        transaction.amount <= 0) {
      return TransferResult.invalidTransaction;
    }

    final db = await _databaseService.database;

    return db.transaction((txn) async {
      final result = await txn.rawQuery('''
      SELECT
        COALESCE(
          SUM(
            CASE
              WHEN type = 'credit' AND status = 'successful'
                THEN amount
              WHEN type = 'debit' AND status = 'successful'
                THEN -amount
              ELSE 0
            END
          ),
          0
        ) AS balance
      FROM transactions
    ''');

      final balance = (result.first['balance'] as num).toDouble();

      if (balance < transaction.amount) {
        return TransferResult.insufficientBalance;
      }

      final transactionMap = transaction.toMap();
      transactionMap.remove('id');

      await txn.insert('transactions', transactionMap);

      return TransferResult.success;
    });
  }

  // Get all transactions, newest first.
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _databaseService.database;

    final result = await db.query('transactions', orderBy: 'date DESC');

    return result.map(TransactionModel.fromMap).toList();
  }

  // Get transactions by type: credit or debit.
  Future<List<TransactionModel>> getTransactionsByType(
    TransactionType type,
  ) async {
    final db = await _databaseService.database;

    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'date DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  // Get transactions by status.
  Future<List<TransactionModel>> getTransactionsByStatus(
    TransactionStatus status,
  ) async {
    final db = await _databaseService.database;

    final result = await db.query(
      'transactions',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'date DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  // Calculate the account balance.
  Future<double> getAccountBalance() async {
    final db = await _databaseService.database;

    final result = await db.rawQuery('''
      SELECT
        COALESCE(
          SUM(
            CASE
              WHEN type = 'credit' AND status = 'successful'
                THEN amount
              WHEN type = 'debit' AND status = 'successful'
                THEN -amount
              ELSE 0
            END
          ),
          0
        ) AS balance
      FROM transactions
    ''');

    return (result.first['balance'] as num).toDouble();
  }
}
