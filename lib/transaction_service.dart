import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction_model.dart';

class TransactionService {
  final _firestore = FirebaseFirestore.instance;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'demo_user';

  Future<void> save(Transaction tx) async {
    final data = {
      'userId': _userId,
      'type': tx.type.name,
      'value': tx.value,
      'date': tx.date,
      'description': tx.description,
      'category': tx.category,
      'anexo': tx.anexo,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (tx.id.isEmpty) {
      await _firestore.collection('transactions').add(data);
    } else {
      await _firestore.collection('transactions').doc(tx.id).update(data);
    }
  }
}
