import 'package:flutter/material.dart';

import '../services/card_service.dart';

class CardProvider extends ChangeNotifier {
  final CardService _cardService = CardService();

  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get cards => _cards;
  bool get isLoading => _isLoading;

  // Load all cards and create a default card if none exists.
  Future<void> loadCards({
    required int userId,
    required String cardholderName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cardService.ensureDefaultCard(
        userId: userId,
        cardholderName: cardholderName,
      );

      _cards = await _cardService.getCardsByUserId(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add another card.
  Future<void> addCard({
    required int userId,
    required String cardholderName,
    String nickname = 'My Debit Card',
  }) async {
    await _cardService.addCard(
      userId: userId,
      cardholderName: cardholderName,
      nickname: nickname,
    );

    _cards = await _cardService.getCardsByUserId(userId);
    notifyListeners();
  }

  // Edit a card nickname.
  Future<void> updateNickname({
    required int cardId,
    required int userId,
    required String nickname,
  }) async {
    debugPrint('1. Starting nickname update');

    final rowsUpdated = await _cardService.updateCardNickname(
      cardId: cardId,
      userId: userId,
      nickname: nickname,
    );

    debugPrint('2. SQLite rows updated: $rowsUpdated');

    _cards = await _cardService.getCardsByUserId(userId);

    debugPrint('3. Cards refreshed: ${_cards.length}');

    notifyListeners();

    debugPrint('4. Card provider notified successfully');
  }

  // Block or unblock a card.
  Future<void> updateStatus({
    required int cardId,
    required int userId,
    required String status,
  }) async {
    await _cardService.updateCardStatus(
      cardId: cardId,
      userId: userId,
      status: status,
    );

    _cards = await _cardService.getCardsByUserId(userId);
    notifyListeners();
  }

  // Delete a card.
  Future<void> deleteCard({required int cardId, required int userId}) async {
    await _cardService.deleteCard(cardId: cardId, userId: userId);

    _cards = await _cardService.getCardsByUserId(userId);
    notifyListeners();
  }
}
