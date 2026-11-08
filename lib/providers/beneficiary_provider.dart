import 'package:flutter/material.dart';

import '../models/beneficiary_model.dart';
import '../services/beneficiary_service.dart';

class BeneficiaryProvider extends ChangeNotifier {
  final BeneficiaryService _beneficiaryService = BeneficiaryService();

  List<BeneficiaryModel> _beneficiaries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BeneficiaryModel> get beneficiaries => _beneficiaries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBeneficiaries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _beneficiaries = await _beneficiaryService.getAllBeneficiaries();
    } catch (e) {
      _errorMessage = 'Unable to load beneficiaries.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addBeneficiary(BeneficiaryModel beneficiary) async {
    try {
      await _beneficiaryService.addBeneficiary(beneficiary);
      await loadBeneficiaries();
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('already exists')
          ? 'This beneficiary already exists.'
          : 'Unable to save beneficiary.';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteBeneficiary(int id) async {
    try {
      await _beneficiaryService.deleteBeneficiary(id);
      await loadBeneficiaries();
    } catch (e) {
      _errorMessage = 'Unable to delete beneficiary.';
      notifyListeners();
    }
  }
}
