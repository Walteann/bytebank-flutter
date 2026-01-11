import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bytebank_flutter/transaction_service.dart';

// =============================================================================
// BALANCE CARD - Integrado com Firestore via TransactionService
// =============================================================================

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _showBalance = true;
  final TransactionService _transactionService = TransactionService();

  void _toggleVisibility() {
    setState(() {
      _showBalance = !_showBalance;
    });
  }

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();

    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    final formatted = formatter.format(absoluteAmount);
    return isNegative ? '-$formatted' : formatted;
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat("EEEE, dd/MM/yyyy", 'pt_BR');
    String formatted = formatter.format(now);
    // Capitalize first letter
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'Usuário';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _transactionService.watchBalance(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // Error state
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        // Normal state
        final balance = snapshot.data ?? 0.0;
        return _buildCard(balance);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF004D61), // AppColors.primary
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Carregando saldo...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade800, size: 32),
          const SizedBox(height: 8),
          Text(
            'Não foi possível carregar as informações do saldo.',
            style: TextStyle(color: Colors.red.shade800, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente novamente mais tarde.',
            style: TextStyle(color: Colors.red.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(double balance) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF004D61), // AppColors.primary
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;

            if (isWide) {
              return _buildWideLayout(balance);
            } else {
              return _buildNarrowLayout(balance);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout(double balance) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Greeting and date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${_getUserName()} :)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getFormattedDate(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        // Right side - Balance
        _buildBalanceSection(balance),
      ],
    );
  }

  Widget _buildNarrowLayout(double balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Text(
          'Olá, ${_getUserName()} :)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Date
        Text(
          _getFormattedDate(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),
        // Balance
        _buildBalanceSection(balance),
      ],
    );
  }

  Widget _buildBalanceSection(double balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saldo header with eye toggle
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Saldo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _toggleVisibility,
              child: Icon(
                _showBalance ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFFFF5031), // AppColors.accent
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Accent divider
        Container(
          width: 200,
          height: 2,
          color: const Color(0xFFFF5031), // AppColors.accent
        ),
        const SizedBox(height: 16),
        // Account type
        const Text(
          'Conta Corrente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        // Balance value
        Text(
          _showBalance ? _formatCurrency(balance) : '••••••••',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
