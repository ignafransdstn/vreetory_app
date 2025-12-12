import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/domain/entities/item_entity.dart';
import '../../../inventory/presentation/provider/item_provider.dart';
import '../../domain/entities/stock_valuation_entity.dart';

class StockValuationReportPage extends ConsumerStatefulWidget {
  const StockValuationReportPage({super.key});

  @override
  ConsumerState<StockValuationReportPage> createState() => _StockValuationReportPageState();
}

class _StockValuationReportPageState extends ConsumerState<StockValuationReportPage> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _selectedSupplier = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(itemProvider.notifier).fetchAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        title: const Text('STOCK VALUATION REPORT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: itemState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemState.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No items to display',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Filter Section
                    _buildFilterSection(itemState.items),
                    const SizedBox(height: 16),
                    // Summary Cards
                    _buildSummaryCards(itemState.items),
                    const SizedBox(height: 24),
                    // Charts
                    _buildChartsSection(itemState.items),
                    const SizedBox(height: 24),
                    // Top Items Table
                    _buildTopItemsSection(itemState.items),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _buildFilterSection(List<ItemEntity> items) {
    final categories = _getUniqueCategories(items);
    final suppliers = _getUniqueSuppliers(items);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            // Category Filter
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['All', ...categories]
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value ?? 'All'),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            // Status Filter
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: ['All', 'Active', 'Inactive']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value ?? 'All'),
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            // Supplier Filter
            DropdownButtonFormField<String>(
              value: _selectedSupplier,
              items: ['All', ...suppliers]
                  .map((sup) => DropdownMenuItem(value: sup, child: Text(sup)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSupplier = value ?? 'All'),
              decoration: InputDecoration(
                labelText: 'Supplier',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<ItemEntity> items) {
    final filtered = _getFilteredItems(items);
    final summary = _calculateSummary(filtered);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Inventory Value',
                value: _formatCurrency(summary.totalInventoryValue),
                color: AppTheme.darkGreen,
                icon: Icons.inventory_2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Potential Revenue',
                value: _formatCurrency(summary.totalPotentialRevenue),
                color: Colors.blue.shade600,
                icon: Icons.trending_up,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Profit',
                value: _formatCurrency(summary.totalProfit),
                color: AppTheme.limeGreen,
                icon: Icons.monetization_on,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Profit Margin',
                value: '${summary.totalProfitMarginPercent.toStringAsFixed(2)}%',
                color: Colors.orange.shade600,
                icon: Icons.percent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Items',
                value: summary.totalItems.toString(),
                color: Colors.purple.shade600,
                icon: Icons.list,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Active Items',
                value: '${summary.activeItems}/${summary.totalItems}',
                color: Colors.green.shade600,
                icon: Icons.check_circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(List<ItemEntity> items) {
    final filtered = _getFilteredItems(items);
    final summary = _calculateSummary(filtered);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visualizations',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        // Pie Chart - Distribution by Category
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribution by Category',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: _buildCategoryPieChartSections(summary),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _buildCategoryLegend(summary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Bar Chart - Top 10 Items by Value
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 10 Items by Inventory Value',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 420,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxBarChartValue(summary.topItemsByValue),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() < summary.topItemsByValue.length) {
                                final item = summary.topItemsByValue[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  child: Transform.rotate(
                                    angle: -1.5708, // -90 degrees
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 150,
                                      alignment: Alignment.center,
                                      child: Text(
                                        item.itemName,
                                        style: const TextStyle(fontSize: 8),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 150,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                _formatCurrencyShort(value),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                            reservedSize: 60,
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarChartGroups(summary.topItemsByValue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopItemsSection(List<ItemEntity> items) {
    final filtered = _getFilteredItems(items);
    final summary = _calculateSummary(filtered);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top 10 Items by Value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Item Code')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Buy Rate')),
                DataColumn(label: Text('Total Value')),
                DataColumn(label: Text('Profit Margin %')),
              ],
              rows: summary.topItemsByValue
                  .map((item) => DataRow(cells: [
                        DataCell(Text(item.itemCode, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item.itemName, style: const TextStyle(fontSize: 11))),
                        DataCell(Text('${item.quantity.toStringAsFixed(2)} ${item.measure}',
                            style: const TextStyle(fontSize: 11))),
                        DataCell(Text(_formatCurrency(item.buyRate), style: const TextStyle(fontSize: 11))),
                        DataCell(Text(_formatCurrency(item.inventoryValue),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        DataCell(Text('${item.profitMarginPercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: item.profitMarginPercent > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ))),
                      ]))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  List<ItemEntity> _getFilteredItems(List<ItemEntity> items) {
    return items.where((item) {
      bool categoryMatch = _selectedCategory == 'All' || item.category == _selectedCategory;
      // Normalize status comparison (case-insensitive)
      bool statusMatch = _selectedStatus == 'All' || 
          item.status.toLowerCase() == _selectedStatus.toLowerCase();
      // Normalize supplier (empty = 'Others')
      var supplier = item.supplier;
      if (supplier.isEmpty || supplier.trim().isEmpty) {
        supplier = 'Others';
      }
      bool supplierMatch = _selectedSupplier == 'All' || supplier == _selectedSupplier;
      return categoryMatch && statusMatch && supplierMatch;
    }).toList();
  }

  StockValuationSummary _calculateSummary(List<ItemEntity> items) {
    double totalInventoryValue = 0;
    double totalPotentialRevenue = 0;
    Map<String, double> valueByCategory = {};
    List<StockValuationItem> valuationItems = [];

    for (var item in items) {
      try {
        final qty = double.tryParse(item.quantity) ?? 0;
        final buyRate = double.tryParse(item.buyRate) ?? 0;
        final sellRate = double.tryParse(item.sellRate) ?? 0;

        final inventoryValue = qty * buyRate;
        final potentialRevenue = qty * sellRate;

        totalInventoryValue += inventoryValue;
        totalPotentialRevenue += potentialRevenue;

        valueByCategory[item.category] = (valueByCategory[item.category] ?? 0) + inventoryValue;

        // Normalize supplier (empty = 'Others')
        var supplier = item.supplier;
        if (supplier.isEmpty || supplier.trim().isEmpty) {
          supplier = 'Others';
        }

        valuationItems.add(StockValuationItem(
          uid: item.uid,
          itemName: item.itemName,
          itemCode: item.itemCode,
          category: item.category,
          quantity: qty,
          buyRate: buyRate,
          sellRate: sellRate,
          measure: item.measure,
          status: item.status,
          supplier: supplier,
        ));
      } catch (e) {
        continue;
      }
    }

    valuationItems.sort((a, b) => b.inventoryValue.compareTo(a.inventoryValue));
    final topItems = valuationItems.take(10).toList();

    int activeItems = items.where((item) => item.status.toLowerCase() == 'active').length;
    int inactiveItems = items.length - activeItems;

    return StockValuationSummary(
      totalInventoryValue: totalInventoryValue,
      totalPotentialRevenue: totalPotentialRevenue,
      totalProfit: totalPotentialRevenue - totalInventoryValue,
      totalItems: items.length,
      activeItems: activeItems,
      inactiveItems: inactiveItems,
      valueByCategory: valueByCategory,
      topItemsByValue: topItems,
    );
  }

  List<PieChartSectionData> _buildCategoryPieChartSections(StockValuationSummary summary) {
    final colors = [
      AppTheme.darkGreen,
      AppTheme.limeGreen,
      Colors.blue.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
    ];

    int colorIndex = 0;
    return summary.valueByCategory.entries.map((entry) {
      final percentage = summary.totalInventoryValue > 0
          ? (entry.value / summary.totalInventoryValue * 100)
          : 0;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        color: color,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarChartGroups(List<StockValuationItem> topItems) {
    return topItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.inventoryValue,
            color: AppTheme.darkGreen,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  double _getMaxBarChartValue(List<StockValuationItem> items) {
    if (items.isEmpty) return 100;
    final maxValue = items.map((e) => e.inventoryValue).reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2;
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'en_US', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  String _formatCurrencyShort(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  List<String> _getUniqueCategories(List<ItemEntity> items) {
    return items.map((e) => e.category).toSet().toList()..sort();
  }

  List<String> _getUniqueSuppliers(List<ItemEntity> items) {
    final suppliers = items.map((e) {
      var supplier = e.supplier;
      // Treat empty suppliers as 'Others'
      if (supplier.isEmpty || supplier.trim().isEmpty) {
        supplier = 'Others';
      }
      return supplier;
    }).toSet().toList();
    suppliers.sort();
    return suppliers;
  }

  List<Widget> _buildCategoryLegend(StockValuationSummary summary) {
    final colors = [
      AppTheme.darkGreen,
      AppTheme.limeGreen,
      Colors.blue.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
    ];

    int colorIndex = 0;
    return summary.valueByCategory.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      final percentage = summary.totalInventoryValue > 0
          ? (entry.value / summary.totalInventoryValue * 100)
          : 0;
      colorIndex++;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key} (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

