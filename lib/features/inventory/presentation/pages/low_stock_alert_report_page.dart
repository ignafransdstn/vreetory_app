import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/low_stock_provider.dart';
import '../../domain/entities/low_stock_alert_item.dart';

class LowStockAlertReportPage extends ConsumerStatefulWidget {
  const LowStockAlertReportPage({super.key});

  @override
  ConsumerState<LowStockAlertReportPage> createState() =>
      _LowStockAlertReportPageState();
}

class _LowStockAlertReportPageState extends ConsumerState<LowStockAlertReportPage> {
  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final filteredItems = ref.watch(filteredLowStockItemsProvider);
    final summary = ref.watch(lowStockSummaryProvider);
    final categories = ref.watch(lowStockCategoriesProvider);
    final suppliers = ref.watch(lowStockSuppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Alert Report'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              summary.when(
                data: (stats) => _buildSummaryCards(stats),
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Text('Error loading summary: $err'),
              ),
              const SizedBox(height: 24),

              // Filter Section
              _buildFilterSection(context, ref, categories, suppliers),
              const SizedBox(height: 24),

              // Chart
              filteredItems.when(
                data: (items) => items.isNotEmpty
                    ? _buildChart(context, items)
                    : const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('No low stock items found'),
                        ),
                      ),
                loading: () => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Text('Error loading chart: $err'),
              ),
              const SizedBox(height: 24),

              // Items List
              _buildItemsHeader(context),
              filteredItems.when(
                data: (items) => items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No items to display')),
                      )
                    : _buildItemsList(context, items),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading items: $err'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build summary cards showing critical, warning, and normal counts
  Widget _buildSummaryCards(
      ({int critical, int warning, int normal, int total}) stats) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Critical',
                count: stats.critical,
                color: Colors.red,
                percentage: stats.total > 0 ? (stats.critical / stats.total * 100) : 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Warning',
                count: stats.warning,
                color: Colors.orange,
                percentage: stats.total > 0 ? (stats.warning / stats.total * 100) : 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Normal',
                count: stats.normal,
                color: Colors.green,
                percentage: stats.total > 0 ? (stats.normal / stats.total * 100) : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter section with checkboxes
  Widget _buildFilterSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<String>> categoriesAsync,
    AsyncValue<List<String>> suppliersAsync,
  ) {
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

            // Status filter
            _buildStatusFilter(ref),
            const SizedBox(height: 12),

            // Category filter
            categoriesAsync.when(
              data: (categories) => _buildCategoryFilter(ref, categories),
              loading: () => const SizedBox(height: 40, child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading categories: $err'),
            ),
            const SizedBox(height: 12),

            // Supplier filter
            suppliersAsync.when(
              data: (suppliers) => _buildSupplierFilter(ref, suppliers),
              loading: () => const SizedBox(height: 40, child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading suppliers: $err'),
            ),
          ],
        ),
      ),
    );
  }

  /// Status filter with checkboxes
  Widget _buildStatusFilter(WidgetRef ref) {
    final selectedStatuses = ref.watch(lowStockStatusFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            _FilterCheckbox(
              label: 'Critical',
              value: selectedStatuses.contains(LowStockStatus.critical),
              onChanged: (checked) {
                final updated = List<LowStockStatus>.from(selectedStatuses);
                if (checked) {
                  updated.add(LowStockStatus.critical);
                } else {
                  updated.remove(LowStockStatus.critical);
                }
                ref
                    .read(lowStockStatusFilterProvider.notifier)
                    .state = updated;
                setState(() => _currentPage = 0);
              },
              color: Colors.red,
            ),
            _FilterCheckbox(
              label: 'Warning',
              value: selectedStatuses.contains(LowStockStatus.warning),
              onChanged: (checked) {
                final updated = List<LowStockStatus>.from(selectedStatuses);
                if (checked) {
                  updated.add(LowStockStatus.warning);
                } else {
                  updated.remove(LowStockStatus.warning);
                }
                ref
                    .read(lowStockStatusFilterProvider.notifier)
                    .state = updated;
                setState(() => _currentPage = 0);
              },
              color: Colors.orange,
            ),
            _FilterCheckbox(
              label: 'Normal',
              value: selectedStatuses.contains(LowStockStatus.normal),
              onChanged: (checked) {
                final updated = List<LowStockStatus>.from(selectedStatuses);
                if (checked) {
                  updated.add(LowStockStatus.normal);
                } else {
                  updated.remove(LowStockStatus.normal);
                }
                ref
                    .read(lowStockStatusFilterProvider.notifier)
                    .state = updated;
                setState(() => _currentPage = 0);
              },
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  /// Category filter with dropdown
  Widget _buildCategoryFilter(WidgetRef ref, List<String> categories) {
    final selectedCategories = ref.watch(lowStockCategoryFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Select category', style: TextStyle(color: Colors.grey[600])),
            ),
            value: null,
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(category),
                ),
              );
            }).toList(),
            onChanged: (selected) {
              if (selected != null && !selectedCategories.contains(selected)) {
                final updated = List<String>.from(selectedCategories);
                updated.add(selected);
                ref.read(lowStockCategoryFilterProvider.notifier).state = updated;
                setState(() => _currentPage = 0);
              }
            },
          ),
        ),
        // Display selected categories as chips
        if (selectedCategories.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: selectedCategories.map((category) {
              return Chip(
                label: Text(category),
                onDeleted: () {
                  final updated = List<String>.from(selectedCategories);
                  updated.remove(category);
                  ref.read(lowStockCategoryFilterProvider.notifier).state = updated;
                  setState(() => _currentPage = 0);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// Supplier filter with dropdown
  Widget _buildSupplierFilter(WidgetRef ref, List<String> suppliers) {
    final selectedSuppliers = ref.watch(lowStockSupplierFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Supplier:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Select supplier', style: TextStyle(color: Colors.grey[600])),
            ),
            value: null,
            items: suppliers.map((supplier) {
              return DropdownMenuItem<String>(
                value: supplier,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(supplier),
                ),
              );
            }).toList(),
            onChanged: (selected) {
              if (selected != null && !selectedSuppliers.contains(selected)) {
                final updated = List<String>.from(selectedSuppliers);
                updated.add(selected);
                ref.read(lowStockSupplierFilterProvider.notifier).state = updated;
                setState(() => _currentPage = 0);
              }
            },
          ),
        ),
        // Display selected suppliers as chips
        if (selectedSuppliers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: selectedSuppliers.map((supplier) {
              return Chip(
                label: Text(supplier),
                onDeleted: () {
                  final updated = List<String>.from(selectedSuppliers);
                  updated.remove(supplier);
                  ref.read(lowStockSupplierFilterProvider.notifier).state = updated;
                  setState(() => _currentPage = 0);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// Build pie chart showing distribution of stock status
  Widget _buildChart(BuildContext context, List<LowStockAlertItem> items) {
    int critical = 0;
    int warning = 0;
    int normal = 0;

    for (var item in items) {
      switch (item.status) {
        case LowStockStatus.critical:
          critical++;
          break;
        case LowStockStatus.warning:
          warning++;
          break;
        case LowStockStatus.normal:
          normal++;
          break;
      }
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribution by Status',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    if (critical > 0)
                      PieChartSectionData(
                        color: Colors.red,
                        value: critical.toDouble(),
                        title: 'Critical\n$critical',
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (warning > 0)
                      PieChartSectionData(
                        color: Colors.orange,
                        value: warning.toDouble(),
                        title: 'Warning\n$warning',
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (normal > 0)
                      PieChartSectionData(
                        color: Colors.green,
                        value: normal.toDouble(),
                        title: 'Normal\n$normal',
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Items list header
  Widget _buildItemsHeader(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Item',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Current',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Minimum',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Items list
  Widget _buildItemsList(BuildContext context, List<LowStockAlertItem> items) {
    int totalPages = (items.length / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    // Ensure current page is valid
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, items.length);
    final paginatedItems = items.sublist(startIndex, endIndex);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paginatedItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = paginatedItems[index];
              return _buildItemRow(context, item);
            },
          ),
          const SizedBox(height: 12),
          // Pagination Controls
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
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
            ),
        ],
      ),
    );
  }

  /// Individual item row
  Widget _buildItemRow(BuildContext context, LowStockAlertItem item) {
    Color statusColor;
    switch (item.status) {
      case LowStockStatus.critical:
        statusColor = Colors.red;
        break;
      case LowStockStatus.warning:
        statusColor = Colors.orange;
        break;
      case LowStockStatus.normal:
        statusColor = Colors.green;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category} • ${item.supplier}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.currentQuantity.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.minimumStock.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.statusLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary card widget
class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final double percentage;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter checkbox widget
class _FilterCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _FilterCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (checked) => onChanged(checked ?? false),
          fillColor: WidgetStateProperty.all(color),
        ),
        Text(label),
      ],
    );
  }
}
