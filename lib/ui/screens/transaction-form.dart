import 'package:bytebank_flutter/file_base64_service.dart';
import 'package:bytebank_flutter/storage_service.dart';
import 'package:bytebank_flutter/transaction_model.dart';
import 'package:bytebank_flutter/transaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? editingTransaction;
  final VoidCallback? onCancel;
  final bool isModal;

  const TransactionForm({
    super.key,
    this.editingTransaction,
    this.onCancel,
    this.isModal = false,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _base64Service = FileBase64Service();

  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  final _valueController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );

  TransactionType? _transactionType;
  String _valueError = '';
  List<String> _filteredCategories = [];
  List<File> _anexos = [];

  final List<String> categories = [
    "Alimentação",
    "Transporte",
    "Educação",
    "Saúde",
    "Lazer",
    "Moradia",
    "Serviços",
    "Salário",
    "Investimentos",
    "Outros",
  ];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );

    if (result == null) return;

    setState(() {
      _anexos = result.paths.whereType<String>().map(File.new).toList();
    });
  }

  bool get isEditMode => widget.editingTransaction != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final tx = widget.editingTransaction!;
      _transactionType = tx.type;
      _descriptionController.text = tx.description;
      _categoryController.text = tx.category;
      _valueController.text = tx.value.toStringAsFixed(2);
      _anexos = [];
    }
  }

  void _handleCategoryChange(String value) {
    setState(() {
      _categoryController.text = value;
      _filteredCategories = value.isEmpty
          ? []
          : categories
                .where((c) => c.toLowerCase().contains(value.toLowerCase()))
                .toList();
    });
  }

  void _handleSelectCategory(String cat) {
    setState(() {
      _categoryController.text = cat;
      _filteredCategories.clear();
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    _valueController.updateValue(0);
    _descriptionController.clear();
    _categoryController.clear();

    setState(() {
      _transactionType = null;
      _filteredCategories.clear();
      _anexos.clear();
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() ||
        _valueError.isNotEmpty ||
        _transactionType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    final base64Files = await _base64Service.filesToBase64(_anexos);

    final transaction = Transaction(
      id: widget.editingTransaction?.id ?? '',
      type: _transactionType!,
      value: _valueController.numberValue,
      date:
          widget.editingTransaction?.date ??
          DateTime.now().toIso8601String().substring(0, 10),
      description: _descriptionController.text,
      category: _categoryController.text,
      anexo: base64Files,
    );

    final transactionService = TransactionService();
    await transactionService.save(transaction);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação salva com sucesso!')),
    );

    if (widget.isModal) {
      Navigator.pop(context, true);
    } else {
      _resetForm();
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode ? 'Editar transação' : 'Nova transação',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<TransactionType>(
              value: _transactionType,
              onChanged: (v) => setState(() => _transactionType = v),
              decoration: const InputDecoration(labelText: 'Tipo de transação'),
              items: const [
                DropdownMenuItem(
                  value: TransactionType.credit,
                  child: Text('Entrada'),
                ),
                DropdownMenuItem(
                  value: TransactionType.debit,
                  child: Text('Saída'),
                ),
              ],
              validator: (v) => v == null ? 'Selecione o tipo' : null,
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Categoria'),
              onChanged: _handleCategoryChange,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe a categoria' : null,
            ),

            if (_filteredCategories.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _filteredCategories
                    .map(
                      (cat) => ActionChip(
                        label: Text(cat),
                        onPressed: () => _handleSelectCategory(cat),
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe a descrição' : null,
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor',
                errorText: _valueError.isNotEmpty ? _valueError : null,
              ),
              validator: (_) {
                if (_valueController.numberValue <= 0) {
                  return 'Digite um valor maior que zero';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            Text('Anexos', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('Adicionar arquivos'),
            ),

            const SizedBox(height: 8),

            if (_anexos.isNotEmpty)
              Column(
                children: _anexos.map((file) {
                  final fileName = file.path.split('/').last;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(fileName),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _anexos.remove(file));
                      },
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 32),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(
                    isEditMode ? 'Atualizar transação' : 'Concluir transação',
                  ),
                ),
                if (isEditMode && widget.onCancel != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancelar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
