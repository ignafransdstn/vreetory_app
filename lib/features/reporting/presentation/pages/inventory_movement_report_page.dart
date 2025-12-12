import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/presentation/provider/inventory_movement_provider.dart';

class InventoryMovementReportPage extends ConsumerStatefulWidget {
  const InventoryMovementReportPage({super.key});

  @override
  ConsumerState<InventoryMovementReportPage> createState() =>
      _InventoryMovementReportPageState();
}

class _InventoryMovementReportPageState
    extends ConsumerState<InventoryMovementReportPage> {
  String _selectedMovementType = 'All';
  String _selectedCategory = 'All';
  String _selectedSupplier = 'All';
  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(inventoryMovementProvider.notifier).fetchInventoryMovements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movementState = ref.watch(inventoryMovementProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        title: const Text('INVENTORY MOVEMENT REPORT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: movementState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : movementState.errorMessage != null
              ? Center(child: Text('Error: ${movementState.errorMessage}'))
              : _buildReportContent(movementState.movements),
    );
  }

  Widget _buildReportContent(List<InventoryMovementItem> movements) {
    final filteredMovements = _getFilteredMovements(movements);
    final inboundCount = movements.where((m) => m.movementType == 'inbound').length;
    final outboundCount = movements.where((m) => m.movementType == 'outbound').length;
    final newItemCount = movements.where((m) => m.movementType == 'new_item').length;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFilterSection(),
          const SizedBox(height: 16),
          _buildSummaryCards(inboundCount, outboundCount, newItemCount),
          const SizedBox(height: 24),
          _buildChartsSection(movements),
          const SizedBox(height: 24),
          _buildMovementListSection(filteredMovements),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final movementState = ref.watch(inventoryMovementProvider);
    
    // Get unique suppliers from movements, treat empty as 'Others'
    final suppliers = <String>{'All'};
    for (final movement in movementState.movements) {
      final supplier = movement.item.supplier.trim().isEmpty 
          ? 'Others' 
          : movement.item.supplier.trim();
      suppliers.add(supplier);
    }
    final supplierList = suppliers.toList()..sort();
    
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
                    value: _selectedMovementType,
                    items: ['All', 'Inbound', 'Outbound', 'New Item']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedMovementType = value ?? 'All'),
                    decoration: InputDecoration(
                      labelText: 'Movement Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: ['All', 'Food', 'Fruit', 'Drink', 'Vegetable', 'Parcel']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value ?? 'All'),
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
              items: supplierList
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

  Widget _buildSummaryCards(int inboundCount, int outboundCount, int newItemCount) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Inbound',
                inboundCount.toString(),
                Icons.arrow_downward,
                AppTheme.limeGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Outbound',
                outboundCount.toString(),
                Icons.arrow_upward,
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'New Item',
                newItemCount.toString(),
                Icons.add_circle,
                Colors.orange,
              ),
            ),
          ],
        ),
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

  Widget _buildChartsSection(List<InventoryMovementItem> movements) {
    final inboundCount = movements.where((m) => m.movementType == 'inbound').length;
    final outboundCount = movements.where((m) => m.movementType == 'outbound').length;
    final newItemCount = movements.where((m) => m.movementType == 'new_item').length;
    
    final categoryMovements = <String, (int, int, int)>{};
    for (final movement in movements) {
      final category = movement.item.category;
      final existing = categoryMovements[category] ?? (0, 0, 0);
      if (movement.movementType == 'inbound') {
        categoryMovements[category] = (existing.$1 + 1, existing.$2, existing.$3);
      } else if (movement.movementType == 'outbound') {
        categoryMovements[category] = (existing.$1, existing.$2 + 1, existing.$3);
      } else if (movement.movementType == 'new_item') {
        categoryMovements[category] = (existing.$1, existing.$2, existing.$3 + 1);
      }
    }

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
                  'Movement Distribution',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (inboundCount > 0)
                          PieChartSectionData(
                            value: inboundCount.toDouble(),
                            title: 'Inbound\n$inboundCount',
                            color: AppTheme.limeGreen,
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        if (outboundCount > 0)
                          PieChartSectionData(
                            value: outboundCount.toDouble(),
                            title: 'Outbound\n$outboundCount',
                            color: Colors.red,
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        if (newItemCount > 0)
                          PieChartSectionData(
                            value: newItemCount.toDouble(),
                            title: 'New Item\n$newItemCount',
                            color: Colors.orange,
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                      centerSpaceRadius: 40,
                      sectionsSpace: 0,
                    ),
                  ),
                ),
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
                  'Movement by Category',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: categoryMovements.isEmpty
                      ? const Center(child: Text('No data'))
                      : BarChart(
                          BarChartData(
                            barGroups: categoryMovements.entries.map((e) {
                              final index = categoryMovements.keys.toList().indexOf(e.key);
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.$1.toDouble(),
                                    color: AppTheme.limeGreen,
                                    width: 6,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                  BarChartRodData(
                                    toY: e.value.$2.toDouble(),
                                    color: Colors.red,
                                    width: 6,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                  BarChartRodData(
                                    toY: e.value.$3.toDouble(),
                                    color: Colors.orange,
                                    width: 6,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final categories = categoryMovements.keys.toList();
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

  Widget _buildMovementListSection(List<InventoryMovementItem> movements) {
    if (movements.isEmpty) {
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
                'No movements found',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final totalPages = (movements.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final paginatedMovements = movements.sublist(
      startIndex,
      endIndex > movements.length ? movements.length : endIndex,
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Movements',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paginatedMovements.length,
              itemBuilder: (context, index) {
                return _buildMovementCard(paginatedMovements[index]);
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
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
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
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
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
        ),
      ),
    );
  }

  Widget _buildMovementCard(InventoryMovementItem movement) {
    late Color color;
    late IconData icon;

    switch (movement.movementType) {
      case 'inbound':
        color = AppTheme.limeGreen;
        icon = Icons.arrow_downward;
        break;
      case 'outbound':
        color = Colors.red;
        icon = Icons.arrow_upward;
        break;
      case 'new_item':
        color = Colors.orange;
        icon = Icons.add_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            movement.item.itemName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${movement.item.itemCode} • ${movement.item.category}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                'Last updated: ${DateFormat('dd/MM/yyyy HH:mm').format(movement.item.updatedAt)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
            trailing: Chip(
            label: Text(
              movement.movementType == 'new_item'
                  ? 'Qty: ${movement.item.quantity}'
                  : '${movement.sign}${movement.quantityChange}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: color,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }

  List<InventoryMovementItem> _getFilteredMovements(
    List<InventoryMovementItem> movements,
  ) {
    final filtered = movements.where((movement) {
      // Movement type filter
      if (_selectedMovementType != 'All') {
        final selectedType = _selectedMovementType.toLowerCase().replaceAll(' ', '_');
        if (movement.movementType != selectedType) return false;
      }

      // Category filter
      if (_selectedCategory != 'All' && movement.item.category != _selectedCategory) {
        return false;
      }
      // Supplier filter
      if (_selectedSupplier != 'All') {
        final itemSupplier = movement.item.supplier.trim().isEmpty 
            ? 'Others' 
            : movement.item.supplier.trim();
        if (itemSupplier != _selectedSupplier) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort by updated_at descending (newest first - paling baru di update di atas)
    filtered.sort((a, b) => b.item.updatedAt.compareTo(a.item.updatedAt));
    return filtered;
  }
}
