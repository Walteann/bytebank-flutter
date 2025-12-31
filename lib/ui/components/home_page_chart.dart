import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =============================================================================
// HOME PAGE CHART - Portado de HomePageChart.tsx (React/Recharts)
// Substituto: fl_chart (adicionar ao pubspec.yaml: fl_chart: ^0.69.0)
// =============================================================================

class HomePageChart extends StatelessWidget {
  final double height;
  final bool showGrid;
  final String title;

  const HomePageChart({
    super.key,
    this.height = 300,
    this.showGrid = true,
    this.title = 'Extrato da Conta',
  });

  // ===========================================================================
  // TODO: MOCK DATA - SUBSTITUIR POR DADOS REAIS DO FIRESTORE
  // ===========================================================================
  static const bool _loading =
      false; // TODO: Conectar ao estado real de loading
  static const bool _error = false; // TODO: Conectar ao estado real de erro
  static const String? _errorMessage = null;

  // Mock transactions - simula dados que viriam do Firestore
  static final List<MockTransaction> _mockTransactions = [
    MockTransaction(date: '2025-01-05', type: 'Credit', value: 3500.00),
    MockTransaction(date: '2025-01-08', type: 'Debit', value: -150.00),
    MockTransaction(date: '2025-01-10', type: 'Debit', value: -85.50),
    MockTransaction(date: '2025-01-12', type: 'Credit', value: 500.00),
    MockTransaction(date: '2025-01-15', type: 'Debit', value: -320.00),
    MockTransaction(date: '2025-01-18', type: 'Debit', value: -95.00),
    MockTransaction(date: '2025-01-20', type: 'Credit', value: 1200.00),
    MockTransaction(date: '2025-01-22', type: 'Debit', value: -450.00),
    MockTransaction(date: '2025-01-25', type: 'Debit', value: -180.00),
    MockTransaction(date: '2025-01-28', type: 'Credit', value: 2800.00),
  ];
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_loading) {
      return _buildContainer(
        child: SizedBox(
          height: height,
          child: const Center(
            child: Text(
              'Carregando extrato...',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Error state
    if (_error) {
      return _buildContainer(
        child: SizedBox(
          height: height,
          child: Center(
            child: Text(
              _errorMessage ?? 'Erro ao carregar dados',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    // Empty state
    if (_mockTransactions.isEmpty) {
      return _buildContainer(
        child: SizedBox(
          height: height,
          child: const Center(
            child: Text(
              'Nenhuma transação encontrada',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Normal state with chart
    final chartData = _processChartData();
    final summaryData = _calculateSummary(chartData);

    return _buildContainer(
      child: Column(
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Chart
          SizedBox(height: height, child: _buildLineChart(chartData)),
          const SizedBox(height: 24),

          // Summary cards
          _buildSummaryCards(summaryData),
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  List<ChartDataPoint> _processChartData() {
    // Sort transactions by date
    final sorted = List<MockTransaction>.from(
      _mockTransactions,
    )..sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    double runningBalance = 0;
    final List<ChartDataPoint> data = [];

    for (int i = 0; i < sorted.length; i++) {
      final transaction = sorted[i];
      final date = DateTime.parse(transaction.date);
      final isCredit = transaction.type == 'Credit';

      runningBalance += transaction.value;

      data.add(
        ChartDataPoint(
          index: i,
          date: date,
          dateLabel: DateFormat('dd/MM').format(date),
          entradas: isCredit ? transaction.value : 0,
          saidas: isCredit ? 0 : transaction.value.abs(),
          saldo: runningBalance,
        ),
      );
    }

    return data;
  }

  SummaryData _calculateSummary(List<ChartDataPoint> chartData) {
    final totalEntradas = chartData.fold<double>(
      0.0,
      (sum, item) => sum + item.entradas,
    );
    final totalSaidas = chartData.fold<double>(
      0.0,
      (sum, item) => sum + item.saidas,
    );
    final double saldoAtual = chartData.isNotEmpty ? chartData.last.saldo : 0.0;

    return SummaryData(
      totalEntradas: totalEntradas,
      totalSaidas: totalSaidas,
      saldoAtual: saldoAtual,
    );
  }

  Widget _buildLineChart(List<ChartDataPoint> chartData) {
    if (chartData.isEmpty) {
      return const Center(child: Text('Sem dados para exibir'));
    }

    // Calculate min/max for Y axis
    final allValues = chartData.map((e) => e.saldo).toList();
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData.length) {
                  // Show every other label to avoid crowding
                  if (index % 2 == 0 || chartData.length <= 5) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        chartData[index].dateLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCurrencyShort(value),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: minY - padding,
        maxY: maxY + padding,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.white,
            tooltipBorder: BorderSide(color: Colors.grey.shade300),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final dataPoint = chartData[index];
                return LineTooltipItem(
                  '${dataPoint.dateLabel}\n',
                  const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Saldo: ${_formatCurrency(dataPoint.saldo)}',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // Saldo line
          LineChartBarData(
            spots: chartData
                .map((e) => FlSpot(e.index.toDouble(), e.saldo))
                .toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            color: const Color(0xFF3B82F6), // blue-500
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF3B82F6),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF3B82F6).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(SummaryData summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  label: 'Total Entradas',
                  value: summary.totalEntradas,
                  backgroundColor: Colors.green.shade50,
                  textColor: Colors.green.shade600,
                  valueColor: Colors.green.shade800,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  label: 'Total Saídas',
                  value: summary.totalSaidas,
                  backgroundColor: Colors.red.shade50,
                  textColor: Colors.red.shade600,
                  valueColor: Colors.red.shade800,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  label: 'Saldo Atual',
                  value: summary.saldoAtual,
                  backgroundColor: Colors.blue.shade50,
                  textColor: Colors.blue.shade600,
                  valueColor: Colors.blue.shade800,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildSummaryCard(
                label: 'Total Entradas',
                value: summary.totalEntradas,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.green.shade600,
                valueColor: Colors.green.shade800,
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(
                label: 'Total Saídas',
                value: summary.totalSaidas,
                backgroundColor: Colors.red.shade50,
                textColor: Colors.red.shade600,
                valueColor: Colors.red.shade800,
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(
                label: 'Saldo Atual',
                value: summary.saldoAtual,
                backgroundColor: Colors.blue.shade50,
                textColor: Colors.blue.shade600,
                valueColor: Colors.blue.shade800,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double value,
    required Color backgroundColor,
    required Color textColor,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _formatCurrencyShort(double amount) {
    if (amount.abs() >= 1000) {
      return 'R\$ ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return 'R\$ ${amount.toStringAsFixed(0)}';
  }
}

// =============================================================================
// HELPER CLASSES
// =============================================================================

class MockTransaction {
  final String date;
  final String type; // 'Credit' or 'Debit'
  final double value;

  MockTransaction({
    required this.date,
    required this.type,
    required this.value,
  });
}

class ChartDataPoint {
  final int index;
  final DateTime date;
  final String dateLabel;
  final double entradas;
  final double saidas;
  final double saldo;

  ChartDataPoint({
    required this.index,
    required this.date,
    required this.dateLabel,
    required this.entradas,
    required this.saidas,
    required this.saldo,
  });
}

class SummaryData {
  final double totalEntradas;
  final double totalSaidas;
  final double saldoAtual;

  SummaryData({
    required this.totalEntradas,
    required this.totalSaidas,
    required this.saldoAtual,
  });
}
