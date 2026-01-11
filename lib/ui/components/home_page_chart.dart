import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bytebank_flutter/transaction_service.dart';

// =============================================================================
// HOME PAGE CHART - Integrado com Firestore via TransactionService
// Usa fl_chart (adicionar ao pubspec.yaml: fl_chart: ^0.69.0)
// =============================================================================

class HomePageChart extends StatefulWidget {
  final double height;
  final bool showGrid;
  final String title;

  const HomePageChart({
    super.key,
    this.height = 300,
    this.showGrid = true,
    this.title = 'Extrato da Conta',
  });

  @override
  State<HomePageChart> createState() => _HomePageChartState();
}

class _HomePageChartState extends State<HomePageChart> {
  final TransactionService _transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChartSummary>(
      stream: _transactionService.watchChartData(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildContainer(
            child: SizedBox(
              height: widget.height,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Carregando extrato...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return _buildContainer(
            child: SizedBox(
              height: widget.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Erro ao carregar dados',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final chartSummary = snapshot.data;

        // Empty state
        if (chartSummary == null || chartSummary.dataPoints.isEmpty) {
          return _buildContainer(
            child: SizedBox(
              height: widget.height,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, color: Colors.grey, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma transação encontrada',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Adicione transações para visualizar o gráfico',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Normal state with chart
        return _buildContainer(
          child: Column(
            children: [
              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Chart
              SizedBox(
                height: widget.height,
                child: _buildLineChart(chartSummary.dataPoints),
              ),
              const SizedBox(height: 24),

              // Summary cards
              _buildSummaryCards(chartSummary),
            ],
          ),
        );
      },
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

  Widget _buildLineChart(List<ChartDataPoint> chartData) {
    if (chartData.isEmpty) {
      return const Center(child: Text('Sem dados para exibir'));
    }

    // Calculate min/max for Y axis
    final allValues = chartData.map((e) => e.saldo).toList();
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range == 0 ? 100.0 : range * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: true,
          horizontalInterval: range == 0 ? 50 : range / 5,
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
              interval: range == 0 ? 50 : range / 4,
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
                if (index < 0 || index >= chartData.length) {
                  return null;
                }
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

  Widget _buildSummaryCards(ChartSummary summary) {
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
