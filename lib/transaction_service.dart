import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction_model.dart';

class TransactionService {
  final _firestore = FirebaseFirestore.instance;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'demo_user';

  CollectionReference get _collection => _firestore.collection('transactions');

  // ==========================================================================
  // SAVE (já existia)
  // ==========================================================================
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
      await _collection.add(data);
    } else {
      await _collection.doc(tx.id).update(data);
    }
  }

  // ==========================================================================
  // DELETE (novo)
  // ==========================================================================
  Future<void> delete(String transactionId) async {
    await _collection.doc(transactionId).delete();
  }

  // ==========================================================================
  // GET ALL TRANSACTIONS FOR CURRENT USER (novo)
  // ==========================================================================
  Future<List<Transaction>> getAll() async {
    final snapshot = await _collection
        .where('userId', isEqualTo: _userId)
        .get();

    return snapshot.docs.map((doc) {
      return Transaction.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }

  // ==========================================================================
  // GET TRANSACTIONS WITH LIMIT (novo) - para RecentTransactions
  // ==========================================================================
  Future<List<Transaction>> getRecent({int limit = 5}) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: _userId)
        .limit(limit)
        .get();

    final transactions = snapshot.docs.map((doc) {
      return Transaction.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();

    // Ordena por data (mais recente primeiro)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  // ==========================================================================
  // STREAM DE TRANSAÇÕES (novo) - para atualizações em tempo real
  // ==========================================================================
  Stream<List<Transaction>> watchAll() {
    return _collection.where('userId', isEqualTo: _userId).snapshots().map((
      snapshot,
    ) {
      final transactions = snapshot.docs.map((doc) {
        return Transaction.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      // Ordena por data (mais recente primeiro)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return transactions;
    });
  }

  // ==========================================================================
  // STREAM DE TRANSAÇÕES RECENTES (novo) - para RecentTransactions widget
  // ==========================================================================
  Stream<List<Transaction>> watchRecent({int limit = 5}) {
    return _collection
        .where('userId', isEqualTo: _userId)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs.map((doc) {
            return Transaction.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

          transactions.sort((a, b) => b.date.compareTo(a.date));

          return transactions;
        });
  }

  // ==========================================================================
  // CALCULAR SALDO (novo) - para BalanceCard
  // ==========================================================================
  Future<double> calculateBalance() async {
    final transactions = await getAll();

    double balance = 0.0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.credit) {
        balance += tx.value;
      } else {
        balance -= tx.value;
      }
    }

    return balance;
  }

  // ==========================================================================
  // STREAM DE SALDO (novo) - para BalanceCard com atualização em tempo real
  // ==========================================================================
  Stream<double> watchBalance() {
    return watchAll().map((transactions) {
      double balance = 0.0;
      for (final tx in transactions) {
        if (tx.type == TransactionType.credit) {
          balance += tx.value;
        } else {
          balance -= tx.value;
        }
      }
      return balance;
    });
  }

  // ==========================================================================
  // DADOS PARA O CHART (novo) - para HomePageChart
  // ==========================================================================
  Future<ChartSummary> getChartData() async {
    final transactions = await getAll();
    return _processChartData(transactions);
  }

  Stream<ChartSummary> watchChartData() {
    return watchAll().map(_processChartData);
  }

  ChartSummary _processChartData(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return ChartSummary(
        dataPoints: [],
        totalEntradas: 0,
        totalSaidas: 0,
        saldoAtual: 0,
      );
    }

    // Ordena por data (mais antiga primeiro para calcular saldo acumulado)
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double runningBalance = 0;
    double totalEntradas = 0;
    double totalSaidas = 0;
    final List<ChartDataPoint> dataPoints = [];

    for (int i = 0; i < sorted.length; i++) {
      final tx = sorted[i];
      final isCredit = tx.type == TransactionType.credit;

      if (isCredit) {
        runningBalance += tx.value;
        totalEntradas += tx.value;
      } else {
        runningBalance -= tx.value;
        totalSaidas += tx.value;
      }

      dataPoints.add(
        ChartDataPoint(
          index: i,
          date: DateTime.parse(tx.date),
          entradas: isCredit ? tx.value : 0,
          saidas: isCredit ? 0 : tx.value,
          saldo: runningBalance,
        ),
      );
    }

    return ChartSummary(
      dataPoints: dataPoints,
      totalEntradas: totalEntradas,
      totalSaidas: totalSaidas,
      saldoAtual: runningBalance,
    );
  }
}

// =============================================================================
// MODELOS AUXILIARES PARA O CHART
// =============================================================================

class ChartDataPoint {
  final int index;
  final DateTime date;
  final double entradas;
  final double saidas;
  final double saldo;

  ChartDataPoint({
    required this.index,
    required this.date,
    required this.entradas,
    required this.saidas,
    required this.saldo,
  });

  String get dateLabel {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

class ChartSummary {
  final List<ChartDataPoint> dataPoints;
  final double totalEntradas;
  final double totalSaidas;
  final double saldoAtual;

  ChartSummary({
    required this.dataPoints,
    required this.totalEntradas,
    required this.totalSaidas,
    required this.saldoAtual,
  });
}
