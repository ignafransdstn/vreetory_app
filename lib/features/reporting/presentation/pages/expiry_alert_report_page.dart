import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/presentation/provider/expiry_alert_provider.dart';
import '../../domain/entities/expiry_alert_entity.dart';

class ExpiryAlertReportPage extends ConsumerStatefulWidget {
  const ExpiryAlertReportPage({super.key});

  @override
  ConsumerState<ExpiryAlertReportPage> createState() =>
      _ExpiryAlertReportPageState();
}

class _ExpiryAlertReportPageState extends ConsumerState<ExpiryAlertReportPage> {
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  String _selectedSupplier = 'All';
  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    // Fetch expiry alert items when page initializes
    Future.microtask(() {
      ref.read(expiryAlertProvider.notifier).fetchExpiryAlertItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expiryAlertState = ref.watch(expiryAlertProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        title: const Text('EXPIRY ALERT REPORT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: expiryAlertState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : expiryAlertState.errorMessage != null
              ? Center(child: Text('Error: ${expiryAlertState.errorMessage}'))
              : _buildReportContent(expiryAlertState.items),
    );
  }

  DateTime? _parseExpiryDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Widget _buildReportContent(List<dynamic> itemsData) {
    final expiryItems = itemsData.map((item) {
      DateTime expiryDate = DateTime.now().add(const Duration(days: 365));
      try {
        if (item.expiredDate != null && item.expiredDate.isNotEmpty) {
          final parsed = _parseExpiryDate(item.expiredDate);
          if (parsed != null) {
            expiryDate = parsed;
          }
        }
      } catch (e) {
        expiryDate = DateTime.now().add(const Duration(days: 365));
      }

      int qty = 0;
      try {
        qty = int.parse(item.quantity.toString());
      } catch (e) {
        qty = 0;
      }

      return ExpiryAlertItem(
        uid: item.uid,
        itemName: item.itemName,
        itemCode: item.itemCode,
        category: item.category,
        quantity: qty,
        expiryDate: expiryDate,
        measure: item.measure,
        supplier: item.supplier,
      );
    }).toList();

    final filteredItems = _getFilteredItems(expiryItems);
    final summary = _calculateSummary(expiryItems);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFilterSection(expiryItems),
          const SizedBox(height: 16),
          _buildAlertSummaryCards(summary),
          const SizedBox(height: 16),
          _buildChartsSection(summary),
          const SizedBox(height: 16),
          _buildAlertsListSection(filteredItems),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterSection(List<ExpiryAlertItem> items) {
    final categories = _getUniqueCategories(items);
    final suppliers = _getUniqueSuppliers(items);
    final statuses = ['All', 'At Risk', 'Expired', 'Today', 'This Week', 'This Month', 'Safe'];

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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: statuses
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? 'All';
                        _currentPage = 0;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: ['All', ...categories]
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'All';
                        _currentPage = 0;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSupplier,
              items: ['All', ...suppliers]
                  .map((sup) => DropdownMenuItem(value: sup, child: Text(sup)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSupplier = value ?? 'All';
                  _currentPage = 0;
                });
              },
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

  Widget _buildAlertSummaryCards(ExpiryAlertSummary summary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Expired',
                  summary.expiredItems.toString(),
                  Icons.error,
                  Colors.red.shade900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Today',
                  summary.expiringTodayItems.toString(),
                  Icons.schedule,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Week',
                  summary.expiringWithinWeekItems.toString(),
                  Icons.calendar_today,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Month',
                  summary.expiringWithinMonthItems.toString(),
                  Icons.date_range,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'At Risk',
                  summary.totalAtRiskItems.toString(),
                  Icons.warning_amber,
                  Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Safe',
                  summary.safeItems.toString(),
                  Icons.check_circle,
                  AppTheme.limeGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(ExpiryAlertSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expiry Status Distribution',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: PieChart(
                    PieChartData(
                      sections: _buildExpiryPieChartSections(summary),
                      centerSpaceRadius: 40,
                      sectionsSpace: 0,
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegend(summary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items by Category',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: _buildCategoryBarChartGroups(summary),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final categories =
                                  summary.itemsByCategory.keys.toList();
                              if (value.toInt() < 0 || value.toInt() >= categories.length) {
                                return const Text('');
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  categories[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
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

  List<PieChartSectionData> _buildExpiryPieChartSections(
      ExpiryAlertSummary summary) {
    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.red.shade900,
      Colors.red,
      Colors.orange,
      Colors.amber,
      AppTheme.limeGreen,
    ];

    final data = [
      (summary.expiredItems, 'Expired', colors[0]),
      (summary.expiringTodayItems, 'Today', colors[1]),
      (summary.expiringWithinWeekItems, 'Week', colors[2]),
      (summary.expiringWithinMonthItems, 'Month', colors[3]),
      (summary.safeItems, 'Safe', colors[4]),
    ];

    for (final (count, _, color) in data) {
      if (summary.totalItems > 0) {
        final percentage = (count / summary.totalItems) * 100;
        if (count > 0) {
          sections.add(
            PieChartSectionData(
              value: count.toDouble(),
              title: '${percentage.toStringAsFixed(1)}%',
              color: color,
              radius: 80,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        }
      }
    }

    return sections;
  }

  List<BarChartGroupData> _buildCategoryBarChartGroups(
      ExpiryAlertSummary summary) {
    final categories = summary.itemsByCategory.keys.toList();
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < categories.length; i++) {
      final count = summary.itemsByCategory[categories[i]] ?? 0;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: AppTheme.darkGreen,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return groups;
  }

  Widget _buildLegend(ExpiryAlertSummary summary) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildLegendItem('Expired', Colors.red.shade900, summary.expiredItems),
        _buildLegendItem('Today', Colors.red, summary.expiringTodayItems),
        _buildLegendItem('Week', Colors.orange, summary.expiringWithinWeekItems),
        _buildLegendItem('Month', Colors.amber, summary.expiringWithinMonthItems),
        _buildLegendItem('Safe', AppTheme.limeGreen, summary.safeItems),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
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
          '$label: $count',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAlertsListSection(List<ExpiryAlertItem> items) {
    if (items.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No expiry alerts',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Sort by days until expiry
    items.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alert Items',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            _buildPaginatedAlertItems(items),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginatedAlertItems(List<ExpiryAlertItem> items) {
    int totalPages = (items.length / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    // Ensure current page is valid
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, items.length);
    final paginatedItems = items.sublist(startIndex, endIndex);

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paginatedItems.length,
          itemBuilder: (context, index) {
            return _buildAlertItemCard(paginatedItems[index]);
          },
        ),
        const SizedBox(height: 16),
        // Pagination Controls
        if (totalPages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page ${_currentPage + 1} of $totalPages',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAlertItemCard(ExpiryAlertItem item) {
    final statusColor = _getStatusColor(item.expiryStatus);
    final statusLabel = _getStatusLabel(item.expiryStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
        ),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          title: Text(
            item.itemName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${item.itemCode} • ${item.category} • Qty: ${item.quantity} ${item.measure}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                'Expiry: ${item.formattedExpiryDate}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: Chip(
            label: Text(
              statusLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: statusColor,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }

  Color _getStatusColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return Colors.red.shade900;
      case ExpiryStatus.expiringToday:
        return Colors.red;
      case ExpiryStatus.expiringWithinWeek:
        return Colors.orange;
      case ExpiryStatus.expiringWithinMonth:
        return Colors.amber;
      case ExpiryStatus.safe:
        return AppTheme.limeGreen;
    }
  }

  String _getStatusLabel(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return 'EXPIRED';
      case ExpiryStatus.expiringToday:
        return 'TODAY';
      case ExpiryStatus.expiringWithinWeek:
        return 'THIS WEEK';
      case ExpiryStatus.expiringWithinMonth:
        return 'THIS MONTH';
      case ExpiryStatus.safe:
        return 'SAFE';
    }
  }

  List<ExpiryAlertItem> _getFilteredItems(List<ExpiryAlertItem> items) {
    return items.where((item) {
      // Status filter
      if (_selectedStatus != 'All') {
        if (_selectedStatus == 'At Risk') {
          // At Risk includes: expired, today, week, and month
          final isAtRisk = item.expiryStatus == ExpiryStatus.expired ||
              item.expiryStatus == ExpiryStatus.expiringToday ||
              item.expiryStatus == ExpiryStatus.expiringWithinWeek ||
              item.expiryStatus == ExpiryStatus.expiringWithinMonth;
          if (!isAtRisk) return false;
        } else {
          final status = _statusStringToEnum(_selectedStatus);
          if (item.expiryStatus != status) return false;
        }
      }

      // Category filter
      if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }
      // Supplier filter
      if (_selectedSupplier != 'All') {
        final itemSupplier = item.supplier.trim().isEmpty 
            ? 'Others' 
            : item.supplier.trim();
        if (itemSupplier != _selectedSupplier) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  ExpiryAlertSummary _calculateSummary(
    List<ExpiryAlertItem> allItems,
  ) {
    int expiredCount = 0;
    int expiringTodayCount = 0;
    int expiringWithinWeekCount = 0;
    int expiringWithinMonthCount = 0;
    int safeCount = 0;
    final Map<String, int> categoryMap = {};

    for (var item in allItems) {
      // Count by expiry status
      switch (item.expiryStatus) {
        case ExpiryStatus.expired:
          expiredCount++;
          break;
        case ExpiryStatus.expiringToday:
          expiringTodayCount++;
          break;
        case ExpiryStatus.expiringWithinWeek:
          expiringWithinWeekCount++;
          break;
        case ExpiryStatus.expiringWithinMonth:
          expiringWithinMonthCount++;
          break;
        case ExpiryStatus.safe:
          safeCount++;
          break;
      }

      // Count by category
      categoryMap[item.category] = (categoryMap[item.category] ?? 0) + 1;
    }

    // Get top risk items
    final topRiskItems = [...allItems]
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore))
      ..take(5)
      ..toList();

    return ExpiryAlertSummary(
      allItems: allItems,
      totalItems: allItems.length,
      expiredItems: expiredCount,
      expiringTodayItems: expiringTodayCount,
      expiringWithinWeekItems: expiringWithinWeekCount,
      expiringWithinMonthItems: expiringWithinMonthCount,
      safeItems: safeCount,
      topRiskItems: topRiskItems,
      itemsByCategory: categoryMap,
    );
  }

  ExpiryStatus _statusStringToEnum(String status) {
    switch (status) {
      case 'Expired':
        return ExpiryStatus.expired;
      case 'Today':
        return ExpiryStatus.expiringToday;
      case 'This Week':
        return ExpiryStatus.expiringWithinWeek;
      case 'This Month':
        return ExpiryStatus.expiringWithinMonth;
      default:
        return ExpiryStatus.safe;
    }
  }

  List<String> _getUniqueCategories(List<ExpiryAlertItem> items) {
    return items.map((item) => item.category).toSet().toList()..sort();
  }

  List<String> _getUniqueSuppliers(List<ExpiryAlertItem> items) {
    final suppliers = <String>{};
    for (final item in items) {
      final supplier = item.supplier.trim().isEmpty 
          ? 'Others' 
          : item.supplier.trim();
      suppliers.add(supplier);
    }
    return suppliers.toList()..sort();
  }
}
