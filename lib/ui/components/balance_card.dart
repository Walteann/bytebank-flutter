import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =============================================================================
// BALANCE CARD - Portado de BalanceCard.tsx (React)
// =============================================================================

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _showBalance = true;

  // ===========================================================================
  // TODO: MOCK DATA - SUBSTITUIR POR DADOS REAIS DO FIRESTORE/AUTH
  // ===========================================================================
  final bool _loading = false; // TODO: Conectar ao estado real de loading
  final bool _error = false; // TODO: Conectar ao estado real de erro
  final String _userName =
      'Ymayro'; // TODO: Buscar de FirebaseAuth.instance.currentUser?.displayName
  final double _currentBalance =
      15750.42; // TODO: Buscar do Firestore (calcular de transactions)
  // ===========================================================================

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

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_loading) {
      return _buildLoadingState();
    }

    // Error state
    if (_error) {
      return _buildErrorState();
    }

    // Normal state
    return _buildCard();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 280,
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
              'Carregando...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Não foi possível carregar as informações do saldo. Tente novamente mais tarde.',
        style: TextStyle(color: Colors.red.shade800, fontSize: 16),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF004D61), // AppColors.primary
        borderRadius: BorderRadius.circular(8),
        // Simula o bg-custom-pixel do CSS (pode adicionar uma imagem depois)
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;

            if (isWide) {
              return _buildWideLayout();
            } else {
              return _buildNarrowLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Greeting and date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, $_userName :)',
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
        _buildBalanceSection(),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Text(
          'Olá, $_userName :)',
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
        _buildBalanceSection(),
      ],
    );
  }

  Widget _buildBalanceSection() {
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
          _showBalance ? _formatCurrency(_currentBalance) : '••••••••',
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
