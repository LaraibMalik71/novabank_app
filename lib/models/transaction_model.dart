enum TransactionType { credit, debit }

enum TransactionStatus { successful, pending, failed }

class TransactionModel {
  final int? id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final String sender;
  final String receiver;
  final DateTime date;
  final TransactionStatus status;

  const TransactionModel({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.sender,
    required this.receiver,
    required this.date,
    required this.status,
  });

  bool get isCredit => type == TransactionType.credit;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type.name,
      'sender': sender,
      'receiver': receiver,
      'date': date.toIso8601String(),
      'status': status.name,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.byName(map['type'] as String),
      sender: map['sender'] as String,
      receiver: map['receiver'] as String,
      date: DateTime.parse(map['date'] as String),
      status: TransactionStatus.values.byName(map['status'] as String),
    );
  }
}
