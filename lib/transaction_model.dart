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
}

final List<Transaction> mockTransactions = [
  Transaction(
    id: 't1',
    type: TransactionType.credit,
    value: 1500.00,
    date: '2025-11-01',
    description: 'Salário',
    category: 'Receita',
    anexo: [],
  ),
  Transaction(
    id: 't2',
    type: TransactionType.debit,
    value: 120.75,
    date: '2025-11-03',
    description: 'Compra supermercado',
    category: 'Alimentação',
    anexo: ['nota1.jpg'],
  ),
  Transaction(
    id: 't3',
    type: TransactionType.debit,
    value: 60.00,
    date: '2025-11-05',
    description: 'Transporte',
    category: 'Transporte',
    anexo: [],
  ),
  Transaction(
    id: 't1',
    type: TransactionType.credit,
    value: 1500.00,
    date: '2025-11-01',
    description: 'Salário',
    category: 'Receita',
    anexo: [],
  ),
  Transaction(
    id: 't2',
    type: TransactionType.debit,
    value: 120.75,
    date: '2025-11-03',
    description: 'Compra supermercado',
    category: 'Alimentação',
    anexo: ['nota1.jpg'],
  ),
  Transaction(
    id: 't3',
    type: TransactionType.debit,
    value: 60.00,
    date: '2025-11-05',
    description: 'Transporte',
    category: 'Transporte',
    anexo: [],
  ),
  Transaction(
    id: 't1',
    type: TransactionType.credit,
    value: 1500.00,
    date: '2025-11-01',
    description: 'Salário',
    category: 'Receita',
    anexo: [],
  ),
  Transaction(
    id: 't2',
    type: TransactionType.debit,
    value: 120.75,
    date: '2025-11-03',
    description: 'Compra supermercado',
    category: 'Alimentação',
    anexo: ['nota1.jpg'],
  ),
  Transaction(
    id: 't3',
    type: TransactionType.debit,
    value: 60.00,
    date: '2025-11-05',
    description: 'Transporte',
    category: 'Transporte',
    anexo: [],
  ),
  Transaction(
    id: 't1',
    type: TransactionType.credit,
    value: 1500.00,
    date: '2025-11-01',
    description: 'Salário',
    category: 'Receita',
    anexo: [],
  ),
  Transaction(
    id: 't2',
    type: TransactionType.debit,
    value: 120.75,
    date: '2025-11-03',
    description: 'Compra supermercado',
    category: 'Alimentação',
    anexo: ['nota1.jpg'],
  ),
  Transaction(
    id: 't3',
    type: TransactionType.debit,
    value: 60.00,
    date: '2025-11-05',
    description: 'Transporte',
    category: 'Transporte',
    anexo: [],
  ),
];
