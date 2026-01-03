import 'package:bytebank_flutter/ui/screens/transaction-form.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../transaction_model.dart';
import 'bytebank.dart';

class ExtratoScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const ExtratoScreen({super.key, required this.transactions});

  @override
  State<ExtratoScreen> createState() => _ExtratoScreenState();
}

class _ExtratoScreenState extends State<ExtratoScreen> {
  late List<Transaction> _allTransitions;
  late List<Transaction> _filteredTransactions;
  DateTimeRange? _dateRange;
  String _selectedCategory = 'Todos';
  String _selectedType = 'Todos'; // 'Todos', 'Crédito', 'Débito'
  bool _onlyWithAttachment = false;
  double? _minValue;
  double? _maxValue;
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _nextId = 5;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'demo_user';

  @override
  void initState() {
    super.initState();
    _allTransitions = [];
    _filteredTransactions = [];
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore) {
        _loadMore();
      }
    });
    // busca inicial do Firestore (se vazio, usa mocks)
    _populateAndFetch();
  }

  Future<void> _openEditTransaction(Transaction tx) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TransactionForm(
            editingTransaction: tx,
            isModal: true,
            onCancel: () => Navigator.pop(context),
          ),
        );
      },
    );

    // se salvou com sucesso, recarrega o extrato
    if (updated == true) {
      await fetchTransactionsFromFirestore(ownerId: _userId);
    }
  }

  Future<void> _populateAndFetch() async {
    try {
      // adiciona uma transação de exemplo
      final tx = Transaction(
        id: '',
        type: TransactionType.credit,
        value: 99.90,
        date: DateTime.now().toIso8601String().substring(0, 10),
        description: 'Transação demo',
        category: 'Teste',
        anexo: [],
      );

      await _firestore.collection('transactions').add(tx.toFirebase(_userId));
      debugPrint('addSampleTransactionToFirebase: sucesso');
    } catch (e, st) {
      // log do erro para DEBUG
      debugPrint('Erro ao adicionar sample transaction: $e');
      debugPrint('$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        await fetchTransactionsFromFirestore(ownerId: _userId);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    // simula delay de rede / processamento
    await Future.delayed(const Duration(milliseconds: 600));

    // gera mais transações mock
    final List<Transaction> more = _generateMoreTransactions(10);
    _allTransitions.addAll(more);

    _applyFilters();

    setState(() => _isLoadingMore = false);
  }

  // adiciona uma transação de exemplo ao Firestore (útil em DEV)
  Future<void> addSampleTransactionToFirebase({
    String ownerId = 'demo_user',
    String type = 'debit',
    double value = 42.0,
    DateTime? date,
    String description = 'Lançamento demo',
    String category = 'Outros',
    List<String> anexo = const [],
  }) async {
    try {
      final doc = {
        'userId': ownerId,
        'type': type,
        'value': value,
        'date': Timestamp.fromDate(date ?? DateTime.now()),
        'description': description,
        'category': category,
        'anexo': anexo,
      };
      final ref = await _firestore
          .collection('transactions')
          .add(doc)
          .timeout(const Duration(seconds: 5));
      debugPrint('Documento criado: ${ref.id}');
    } catch (e, st) {
      debugPrint('Erro em addSampleTransactionToFirebase: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  //firestore fetch dados usuario
  Future<void> fetchTransactionsFromFirestore({
    String ownerId = 'demo_user',
  }) async {
    setState(() => _isLoadingMore = true);
    try {
      final snap = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: ownerId)
          // .orderBy('date', descending: true) // Comentado por causa do erro de índice
          .get()
          .timeout(const Duration(seconds: 5));

      if (snap.docs.isNotEmpty) {
        _allTransitions = snap.docs.map((d) {
          final data = d.data();
          final dateField = data['date'];
          String dateStr;
          if (dateField is Timestamp) {
            dateStr = dateField.toDate().toIso8601String().substring(0, 10);
          } else if (dateField is String) {
            dateStr = dateField;
          } else {
            dateStr = DateTime.now().toIso8601String().substring(0, 10);
          }
          final typeStr = (data['type'] ?? 'debit').toString().toLowerCase();
          final type = typeStr.contains('credit')
              ? TransactionType.credit
              : TransactionType.debit;
          final value = (data['value'] is num)
              ? (data['value'] as num).toDouble()
              : double.tryParse('${data['value']}') ?? 0.0;
          final description = (data['description'] ?? '').toString();
          final category = (data['category'] ?? 'Outros').toString();
          final anexoDyn = data['anexo'];
          final anexo = <String>[];
          if (anexoDyn is List) {
            for (var e in anexoDyn) {
              if (e != null) anexo.add(e.toString());
            }
          }
          return Transaction(
            id: d.id,
            type: type,
            value: value,
            date: dateStr,
            description: description,
            category: category,
            anexo: anexo,
          );
        }).toList();
        debugPrint(
          'fetchTransactionsFromFirestore: encontrou ${_allTransitions.length} docs',
        );
      } else {
        // fallback para mocks caso não haja docs para o ownerId
        debugPrint(
          'fetchTransactionsFromFirestore: nenhuma doc encontrada, usando mocks',
        );
        _allTransitions = List.from(widget.transactions);
      }
      _applyFilters();
    } catch (e, st) {
      // se erro, mantém mocks locais
      debugPrint('Erro ao buscar transações: $e');
      debugPrint('$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar dados: $e. Usando mocks.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _allTransitions = List.from(widget.transactions);
      _applyFilters();
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  List<Transaction> _generateMoreTransactions(int count) {
    final List<Transaction> out = [];
    final now = DateTime.now();
    for (var i = 0; i < count; i++) {
      final id = 't${_nextId++}';
      final daysAgo = (_nextId + i) % 30;
      final date = now.subtract(Duration(days: daysAgo));
      final type = (i % 3 == 0)
          ? TransactionType.credit
          : TransactionType.debit;
      final value = (20 + (i * 7)) + (i % 5) * 0.75;
      final category = (i % 2 == 0) ? 'Alimentação' : 'Serviços';
      out.add(
        Transaction(
          id: id,
          type: type,
          value: double.parse(value.toStringAsFixed(2)),
          date: date.toIso8601String().substring(0, 10),
          description: 'Lançamento $id',
          category: category,
          anexo: (i % 4 == 0) ? ['nota_$id.jpg'] : [],
        ),
      );
    }
    return out;
  }

  void _applyFilters() {
    final List<Transaction> all = _allTransitions;
    setState(() {
      _filteredTransactions = all.where((tx) {
        // data
        if (_dateRange != null) {
          final txDate = DateTime.tryParse(tx.date);
          if (txDate == null) return false;
          if (txDate.isBefore(_dateRange!.start) ||
              txDate.isAfter(_dateRange!.end)) {
            return false;
          }
        }

        // categoria
        if (_selectedCategory != 'Todos' && tx.category != _selectedCategory) {
          return false;
        }

        // tipo de transacao
        if (_selectedType != 'Todos') {
          if (_selectedType == 'Crédito' && tx.type != TransactionType.credit) {
            return false;
          }
          if (_selectedType == 'Débito' && tx.type != TransactionType.debit) {
            return false;
          }
        }

        // anexo
        if (_onlyWithAttachment && tx.anexo.isEmpty) return false;

        // valor min / max
        if (_minValue != null && tx.value < _minValue!) return false;
        if (_maxValue != null && tx.value > _maxValue!) return false;

        // descricao oui categoria
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          if (!tx.description.toLowerCase().contains(q) &&
              !tx.category.toLowerCase().contains(q)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _selectedCategory = 'Todos';
      _selectedType = 'Todos';
      _onlyWithAttachment = false;
      _minValue = null;
      _maxValue = null;
      _searchQuery = '';
      _filteredTransactions = List.from(_allTransitions);
    });
  }

  Color _colorForType(TransactionType type) =>
      type == TransactionType.credit ? Colors.green : Colors.red;

  String _signForType(TransactionType type) =>
      type == TransactionType.credit ? '+' : '-';

  String _formatDateRangeLabel() {
    if (_dateRange == null) return 'Todas as datas';
    return '${_dateRange!.start.toIso8601String().substring(0, 10)} → ${_dateRange!.end.toIso8601String().substring(0, 10)}';
  }

  Future<void> _openFilterSheet() async {
    final categories = <String>{'Todos'};
    categories.addAll(_allTransitions.map((t) => t.category));
    final catList = categories.toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        DateTimeRange? auxRange = _dateRange;
        String tempCategory = _selectedCategory;
        String tempType = _selectedType;
        bool tempOnlyWithAttachment = _onlyWithAttachment;
        final TextEditingController minController = TextEditingController(
          text: _minValue?.toString() ?? '',
        );
        final TextEditingController maxController = TextEditingController(
          text: _maxValue?.toString() ?? '',
        );
        final TextEditingController searchController = TextEditingController(
          text: _searchQuery,
        );

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Filtros',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                auxRange = null;
                                tempCategory = 'Todos';
                                tempType = 'Todos';
                                tempOnlyWithAttachment = false;
                                minController.clear();
                                maxController.clear();
                                searchController.clear();
                              });
                            },
                            child: Text('Limpar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Fechar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar (descrição ou categoria)',
                        ),
                        onChanged: (v) => setModalState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  initialDateRange: auxRange,
                                );
                                if (picked != null) {
                                  setModalState(() => auxRange = picked);
                                }
                              },
                              child: Text(
                                auxRange == null
                                    ? 'Selecionar intervalo'
                                    : '${auxRange!.start.toIso8601String().substring(0, 10)} → ${auxRange!.end.toIso8601String().substring(0, 10)}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: tempCategory,
                              items: catList
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setModalState(
                                () => tempCategory = v ?? 'Todos',
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: tempType,
                              items: ['Todos', 'Crédito', 'Débito']
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setModalState(() => tempType = v ?? 'Todos'),
                              decoration: const InputDecoration(
                                labelText: 'Tipo',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                const Text('Somente com anexos'),
                                const SizedBox(width: 8),
                                Switch(
                                  value: tempOnlyWithAttachment,
                                  onChanged: (v) => setModalState(
                                    () => tempOnlyWithAttachment = v,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minController,
                              decoration: const InputDecoration(
                                labelText: 'Valor mínimo',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: maxController,
                              decoration: const InputDecoration(
                                labelText: 'Valor máximo',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _dateRange = auxRange;
                                  _selectedCategory = tempCategory;
                                  _selectedType = tempType;
                                  _onlyWithAttachment = tempOnlyWithAttachment;
                                  _minValue = double.tryParse(
                                    minController.text,
                                  );
                                  _maxValue = double.tryParse(
                                    maxController.text,
                                  );
                                  _searchQuery = searchController.text;
                                });
                                _applyFilters();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004D61),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Aplicar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  auxRange = null;
                                  tempCategory = 'Todos';
                                  tempType = 'Todos';
                                  tempOnlyWithAttachment = false;
                                  minController.clear();
                                  maxController.clear();
                                  searchController.clear();
                                });

                                setState(() {
                                  _clearFilters();
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text('Limpar tudo'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4EDE3),
      body: Column(
        children: [
          const BytebankHeader(),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF004D61),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  const Text(
                    'Extrato',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Color(0xFF004D61)),
                onPressed: _openFilterSheet,
                tooltip: 'Filtros',
              ),
            ],
          ),
          if (_dateRange != null ||
              _selectedCategory != 'Todos' ||
              _selectedType != 'Todos' ||
              _onlyWithAttachment ||
              _minValue != null ||
              _maxValue != null ||
              _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_dateRange != null)
                          Chip(label: Text(_formatDateRangeLabel())),
                        if (_selectedCategory != 'Todos')
                          Chip(label: Text('Categoria: $_selectedCategory')),
                        if (_selectedType != 'Todos')
                          Chip(label: Text('Tipo: $_selectedType')),
                        if (_onlyWithAttachment)
                          const Chip(label: Text('Com anexos')),
                        if (_minValue != null)
                          Chip(
                            label: Text(
                              'Min: R\$ ${_minValue!.toStringAsFixed(2)}',
                            ),
                          ),
                        if (_maxValue != null)
                          Chip(
                            label: Text(
                              'Max: R\$ ${_maxValue!.toStringAsFixed(2)}',
                            ),
                          ),
                        if (_searchQuery.isNotEmpty)
                          Chip(label: Text('Busca: $_searchQuery')),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.close),
                    tooltip: 'Limpar filtros',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = _filteredTransactions[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _openEditTransaction(tx),
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _colorForType(
                        tx.type,
                      ).withValues(alpha: 0.1),
                      child: Icon(
                        tx.type == TransactionType.credit
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: _colorForType(tx.type),
                      ),
                    ),
                    title: Text(
                      tx.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          tx.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_signForType(tx.type)} R\$ ${tx.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _colorForType(tx.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (tx.anexo.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attachment, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${tx.anexo.length}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
