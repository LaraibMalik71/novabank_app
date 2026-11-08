class BeneficiaryModel {
  final int? id;
  final String name;
  final String accountNumber;
  final String bankName;
  final String beneficiaryType;
  final DateTime createdAt;

  const BeneficiaryModel({
    this.id,
    required this.name,
    required this.accountNumber,
    required this.bankName,
    required this.beneficiaryType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'account_number': accountNumber,
      'bank_name': bankName,
      'beneficiary_type': beneficiaryType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BeneficiaryModel.fromMap(Map<String, dynamic> map) {
    return BeneficiaryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      accountNumber: map['account_number'] as String,
      bankName: map['bank_name'] as String,
      beneficiaryType: map['beneficiary_type'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
