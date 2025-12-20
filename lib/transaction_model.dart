import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum TransactionType { credit, debit }

class Transaction {
  final String id;
  final TransactionType type;
  final double value;
  final String date;
  final String description;
  final String category;
  final List<String> anexo;

  Transaction({
    required this.id,
    required this.type,
    required this.value,
    required this.date,
    required this.description,
    required this.category,
    required this.anexo,
  });

  factory Transaction.fromFirestore(String id, Map<String, dynamic> data) {
    final dateField = data['date'];

    return Transaction(
      id: id,
      type: (data['type'] ?? 'debit') == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      value: (data['value'] as num).toDouble(),
      date: dateField is Timestamp
          ? dateField.toDate().toIso8601String().substring(0, 10)
          : dateField.toString(),
      description: data['description'] ?? '',
      category: data['category'] ?? 'Outros',
      anexo: List<String>.from(data['anexo'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore(String userId) {
    return {
      'userId': userId,
      'type': type.name,
      'value': value,
      'date': Timestamp.fromDate(DateTime.parse(date)),
      'description': description,
      'category': category,
      'anexo': anexo,
    };
  }
}
