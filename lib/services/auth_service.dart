import 'package:cryptography/cryptography.dart';

import 'database_service.dart';

import 'dart:math' as math;

class AuthService {
  final DatabaseService _databaseService = DatabaseService.instance;
  Future<String> _generateUniqueAccountNumber() async {
    final db = await _databaseService.database;
    final random = math.Random.secure();

    while (true) {
      final accountNumber = List.generate(
        16,
        (index) => index == 0 ? random.nextInt(9) + 1 : random.nextInt(10),
      ).join();

      final existing = await db.query(
        'users',
        columns: ['id'],
        where: 'account_number = ?',
        whereArgs: [accountNumber],
        limit: 1,
      );

      if (existing.isEmpty) {
        return accountNumber;
      }
    }
  }

  final Pbkdf2 _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  Future<String> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await _databaseService.database;

    final normalizedEmail = email.trim().toLowerCase();

    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (existingUser.isNotEmpty) {
      return 'An account with this email already exists.';
    }

    final random = math.Random.secure();

    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));

    final passwordHash = await _algorithm.deriveKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: saltBytes,
    );

    final hashBytes = await passwordHash.extractBytes();

    final accountNumber = await _generateUniqueAccountNumber();

    await db.insert('users', {
      'name': name.trim(),
      'email': normalizedEmail,
      'phone': phone.trim(),
      'password_hash': hashBytes.join(','),
      'password_salt': saltBytes.join(','),
      'account_number': accountNumber,
    });

    return 'success';
  }

  Future<bool> login({required String email, required String password}) async {
    final db = await _databaseService.database;

    final users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );

    if (users.isEmpty) {
      return false;
    }

    final user = users.first;

    final saltBytes = (user['password_salt'] as String)
        .split(',')
        .map(int.parse)
        .toList();

    final storedHash = (user['password_hash'] as String)
        .split(',')
        .map(int.parse)
        .toList();

    final passwordHash = await _algorithm.deriveKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: saltBytes,
    );

    final enteredHash = await passwordHash.extractBytes();

    if (enteredHash.length != storedHash.length) {
      return false;
    }

    for (int i = 0; i < enteredHash.length; i++) {
      if (enteredHash[i] != storedHash[i]) {
        return false;
      }
    }

    return true;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _databaseService.database;

    final users = await db.query(
      'users',
      columns: ['id', 'name', 'email', 'phone', 'account_number'],
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );

    if (users.isEmpty) {
      return null;
    }

    final user = Map<String, dynamic>.from(users.first);

    // Generate an account number if this user does not have one.
    if (user['account_number'] == null ||
        (user['account_number'] as String).isEmpty) {
      final accountNumber = await _generateUniqueAccountNumber();

      await db.update(
        'users',
        {'account_number': accountNumber},
        where: 'id = ?',
        whereArgs: [user['id']],
      );

      user['account_number'] = accountNumber;
    }

    return user;
  }

  Future<String?> updateUserProfile({
    required int userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final db = await _databaseService.database;

    final normalizedEmail = email.trim().toLowerCase();

    final existingUser = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ? AND id != ?',
      whereArgs: [normalizedEmail, userId],
    );

    if (existingUser.isNotEmpty) {
      return 'An account with this email already exists.';
    }

    await db.update(
      'users',
      {'name': name.trim(), 'email': normalizedEmail, 'phone': phone.trim()},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return null;
  }

  Future<String?> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final db = await _databaseService.database;

    final users = await db.query(
      'users',
      columns: ['password_hash', 'password_salt'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) {
      return 'Account not found. Please log in again.';
    }

    final user = users.first;

    // Verify the current password.
    final saltBytes = (user['password_salt'] as String)
        .split(',')
        .map(int.parse)
        .toList();

    final storedHash = (user['password_hash'] as String)
        .split(',')
        .map(int.parse)
        .toList();

    final currentHash = await _algorithm.deriveKey(
      secretKey: SecretKey(currentPassword.codeUnits),
      nonce: saltBytes,
    );

    final currentHashBytes = await currentHash.extractBytes();

    if (currentHashBytes.length != storedHash.length) {
      return 'Current password is incorrect.';
    }

    for (int i = 0; i < currentHashBytes.length; i++) {
      if (currentHashBytes[i] != storedHash[i]) {
        return 'Current password is incorrect.';
      }
    }

    // Generate a new salt and hash the new password.
    final random = math.Random.secure();

    final newSalt = List<int>.generate(16, (_) => random.nextInt(256));

    final newHash = await _algorithm.deriveKey(
      secretKey: SecretKey(newPassword.codeUnits),
      nonce: newSalt,
    );

    final newHashBytes = await newHash.extractBytes();

    await db.update(
      'users',
      {
        'password_hash': newHashBytes.join(','),
        'password_salt': newSalt.join(','),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    return null;
  }
}
