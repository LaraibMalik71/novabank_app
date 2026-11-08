import 'dart:math' as math;

import 'database_service.dart';

class CardService {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Generate a unique 16-digit demo card number.
  Future<String> _generateUniqueCardNumber() async {
    final db = await _databaseService.database;
    final random = math.Random.secure();

    while (true) {
      final cardNumber = List.generate(
        16,
        (index) => index == 0 ? random.nextInt(9) + 1 : random.nextInt(10),
      ).join();

      final existing = await db.query(
        'cards',
        columns: ['id'],
        where: 'card_number = ?',
        whereArgs: [cardNumber],
        limit: 1,
      );

      if (existing.isEmpty) {
        return cardNumber;
      }
    }
  }

  // Load all cards belonging to a user.
  Future<List<Map<String, dynamic>>> getCardsByUserId(int userId) async {
    final db = await _databaseService.database;

    return db.query(
      'cards',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_primary DESC, created_at ASC',
    );
  }

  // Add a new card for a user.
  Future<int> addCard({
    required int userId,
    required String cardholderName,
    String nickname = 'My Debit Card',
  }) async {
    final db = await _databaseService.database;

    final existingCards = await getCardsByUserId(userId);
    final cardNumber = await _generateUniqueCardNumber();

    return db.insert('cards', {
      'user_id': userId,
      'card_number': cardNumber,
      'cardholder_name': cardholderName.trim(),
      'nickname': nickname.trim(),
      'status': 'Active',
      'is_primary': existingCards.isEmpty ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Create the first card if the user does not have one.
  Future<void> ensureDefaultCard({
    required int userId,
    required String cardholderName,
  }) async {
    final cards = await getCardsByUserId(userId);

    if (cards.isEmpty) {
      await addCard(userId: userId, cardholderName: cardholderName);
    }
  }

  // Update a card's nickname.
  Future<int> updateCardNickname({
    required int cardId,
    required int userId,
    required String nickname,
  }) async {
    final db = await _databaseService.database;

    return db.update(
      'cards',
      {'nickname': nickname.trim()},
      where: 'id = ? AND user_id = ?',
      whereArgs: [cardId, userId],
    );
  }

  // Update a card's status.
  Future<int> updateCardStatus({
    required int cardId,
    required int userId,
    required String status,
  }) async {
    if (status != 'Active' && status != 'Blocked') {
      throw ArgumentError('Invalid card status.');
    }

    final db = await _databaseService.database;

    return db.update(
      'cards',
      {'status': status},
      where: 'id = ? AND user_id = ?',
      whereArgs: [cardId, userId],
    );
  }

  // Delete a card.
  Future<int> deleteCard({required int cardId, required int userId}) async {
    final db = await _databaseService.database;

    return db.delete(
      'cards',
      where: 'id = ? AND user_id = ?',
      whereArgs: [cardId, userId],
    );
  }
}
