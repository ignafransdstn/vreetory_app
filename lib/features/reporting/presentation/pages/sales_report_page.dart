import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../providers/sales_report_provider.dart';
import '../utils/sales_excel_exporter.dart';

class SalesReportPage extends ConsumerStatefulWidget {
  const SalesReportPage({super.key});

  @override
  ConsumerState<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends ConsumerState<SalesReportPage> {
  @override
  void initState() {
    super.initState();
    // Set default date range to today
    Future.microtask(() {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      ref.read(selectedDateRangeProvider.notifier).state =
          DateTimeRange(start: startOfDay, end: endOfDay);
    });
  }

  Future<void> _selectDateRange() async {
    final currentRange = ref.read(selectedDateRangeProvider);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: currentRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.darkGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final startOfDay = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      final endOfDay = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );
      ref.read(selectedDateRangeProvider.notifier).state =
          DateTimeRange(start: startOfDay, end: endOfDay);
    }
  }

  void _selectQuickRange(QuickRangeType type) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (type) {
      case QuickRangeType.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case QuickRangeType.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case QuickRangeType.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case QuickRangeType.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case QuickRangeType.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
    }

    ref.read(selectedDateRangeProvider.notifier).state =
        DateTimeRange(start: startDate, end: endDate);
  }

  Future<void> _exportToExcel(
    List<dynamic> transactions,
    dynamic salesSummary,
    DateTimeRange dateRange,
  ) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Membuat file Excel...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await SalesExcelExporter.exportReconciliationReport(
        transactions: transactions.cast(),
        summary: salesSummary,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File Excel berhasil dibuat dan siap dibagikan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error export Excel: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(salesTransactionsProvider);
    final salesSummary = ref.watch(salesSummaryProvider);
    final dateRange = ref.watch(selectedDateRangeProvider);
    final viewMode = ref.watch(salesViewModeProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        title: const Text('SALES REPORT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: transactionsAsync.when(
          data: (transactions) => [
            if (salesSummary != null && dateRange != null)
              IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'Export Excel',
                onPressed: () =>
                    _exportToExcel(transactions, salesSummary, dateRange),
              ),
          ],
          loading: () => [],
          error: (_, __) => [],
        ),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        data: (transactions) {
          if (salesSummary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No sales data for selected period',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: const Text('Select Date Range'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date Range Filter Card
              _buildDateRangeCard(dateRange),
              const SizedBox(height: 16),
              // Quick Range Buttons
              _buildQuickRangeButtons(),
              const SizedBox(height: 16),
              // View Mode Toggle
              _buildViewModeToggle(viewMode),
              const SizedBox(height: 16),
              // Summary Cards
              _buildSummaryCards(salesSummary),
              const SizedBox(height: 24),
              // Sales Chart
              _buildSalesChart(),
              const SizedBox(height: 24),
              // Payment Method Breakdown
              _buildPaymentMethodBreakdown(salesSummary),
              const SizedBox(height: 24),
              // Top Selling Items
              _buildTopSellingItems(),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateRangeCard(DateTimeRange? dateRange) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Period:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateRange != null
                        ? '${dateFormat.format(dateRange.start)} - ${dateFormat.format(dateRange.end)}'
                        : 'Select date range',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.date_range, color: AppTheme.darkGreen),
              onPressed: _selectDateRange,
              tooltip: 'Change date range',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRangeButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickRangeButton(
            label: 'Today',
            onPressed: () => _selectQuickRange(QuickRangeType.today),
          ),
          const SizedBox(width: 8),
          _QuickRangeButton(
            label: 'Yesterday',
            onPressed: () => _selectQuickRange(QuickRangeType.yesterday),
          ),
          const SizedBox(width: 8),
          _QuickRangeButton(
            label: 'This Week',
            onPressed: () => _selectQuickRange(QuickRangeType.thisWeek),
          ),
          const SizedBox(width: 8),
          _QuickRangeButton(
            label: 'This Month',
            onPressed: () => _selectQuickRange(QuickRangeType.thisMonth),
          ),
          const SizedBox(width: 8),
          _QuickRangeButton(
            label: 'Last Month',
            onPressed: () => _selectQuickRange(QuickRangeType.lastMonth),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle(SalesViewMode currentMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _ViewModeButton(
                label: 'Daily',
                isSelected: currentMode == SalesViewMode.daily,
                onPressed: () => ref
                    .read(salesViewModeProvider.notifier)
                    .state = SalesViewMode.daily,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ViewModeButton(
                label: 'Monthly',
                isSelected: currentMode == SalesViewMode.monthly,
                onPressed: () => ref
                    .read(salesViewModeProvider.notifier)
                    .state = SalesViewMode.monthly,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(salesSummary) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Sales',
                value: currencyFormat.format(salesSummary.totalSales),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Transactions',
                value: salesSummary.totalTransactions.toString(),
                icon: Icons.receipt,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Profit',
                value: currencyFormat.format(salesSummary.totalProfit),
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Avg Transaction',
                value: currencyFormat.format(salesSummary.averageTransaction),
                icon: Icons.show_chart,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Items Sold',
                value: salesSummary.totalItemsSold.toString(),
                icon: Icons.shopping_cart,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Discount',
                value: currencyFormat.format(salesSummary.totalDiscount),
                icon: Icons.discount,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    final dailyData = ref.watch(dailySalesDataProvider);
    final viewMode = ref.watch(salesViewModeProvider);

    if (dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              viewMode == SalesViewMode.daily
                  ? 'Daily Sales Trend'
                  : 'Monthly Sales Trend',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: dailyData.isNotEmpty
                        ? dailyData
                                .map((e) => e.sales)
                                .reduce((a, b) => a > b ? a : b) /
                            5
                        : 1000000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormat.compact(locale: 'id_ID').format(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < dailyData.length) {
                            final date = dailyData[value.toInt()].date;
                            return Text(
                              viewMode == SalesViewMode.daily
                                  ? DateFormat('dd/MM').format(date)
                                  : DateFormat('MMM').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.sales,
                              ))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.darkGreen,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.darkGreen.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodBreakdown(salesSummary) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final paymentMethods = salesSummary.paymentMethodBreakdown;

    if (paymentMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate total for percentage
    final total = paymentMethods.values.reduce((double a, double b) => a + b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...paymentMethods.entries.map((entry) {
              final percentage = (entry.value / total * 100).toStringAsFixed(1);
              final count = salesSummary.paymentMethodCount[entry.key] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getPaymentMethodIcon(entry.key),
                              size: 20,
                              color: _getPaymentMethodColor(entry.key),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($count txn)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currencyFormat.format(entry.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: entry.value / total,
                              backgroundColor: Colors.grey.shade200,
                              color: _getPaymentMethodColor(entry.key),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingItems() {
    final topItems = ref.watch(topSellingItemsProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (topItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Selling Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topItems.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = topItems[index];
                return Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: index < 3
                            ? AppTheme.brightYellow.withValues(alpha: 0.2)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: index < 3
                                ? AppTheme.darkGreen
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${QuantityFormatter.format(item.quantitySold.toString())} units',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          currencyFormat.format(item.totalRevenue),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'transfer':
        return Icons.account_balance;
      case 'qris':
        return Icons.qr_code_2;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'transfer':
        return Colors.blue;
      case 'qris':
        return Colors.purple;
      case 'card':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRangeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickRangeButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.darkGreen),
        foregroundColor: AppTheme.darkGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ViewModeButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.darkGreen : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
}

enum QuickRangeType {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
}
