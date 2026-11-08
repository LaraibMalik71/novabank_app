import '../models/beneficiary_model.dart';
import 'database_service.dart';

class BeneficiaryService {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<int> addBeneficiary(BeneficiaryModel beneficiary) async {
    final db = await _databaseService.database;

    final existing = await db.query(
      'beneficiaries',
      where: 'account_number = ? AND bank_name = ?',
      whereArgs: [beneficiary.accountNumber, beneficiary.bankName],
    );

    if (existing.isNotEmpty) {
      throw Exception('This beneficiary already exists.');
    }

    final beneficiaryMap = beneficiary.toMap();
    beneficiaryMap.remove('id');

    return db.insert('beneficiaries', beneficiaryMap);
  }

  Future<List<BeneficiaryModel>> getAllBeneficiaries() async {
    final db = await _databaseService.database;

    final result = await db.query('beneficiaries', orderBy: 'created_at DESC');

    return result.map((map) {
      return BeneficiaryModel.fromMap(map);
    }).toList();
  }

  Future<int> deleteBeneficiary(int id) async {
    final db = await _databaseService.database;

    return db.delete('beneficiaries', where: 'id = ?', whereArgs: [id]);
  }
}
