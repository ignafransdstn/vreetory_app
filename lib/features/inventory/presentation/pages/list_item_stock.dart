// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item_entity.dart';
import '../provider/item_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../reporting/data/models/loss_record_model.dart';
import '../../../reporting/data/datasources/loss_record_remote_datasource.dart';
import '../../../reporting/domain/entities/loss_record_entity.dart';
import 'edit_item_field.dart';

class ListItemStockPage extends ConsumerStatefulWidget {
  const ListItemStockPage({super.key});

  @override
  ConsumerState<ListItemStockPage> createState() => _ListItemStockPageState();
}

class _ListItemStockPageState extends ConsumerState<ListItemStockPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Filter states
  bool _filterLowStock = false;
  bool _filterActive = true;
  bool _filterInactive = true;
  bool _sortByLatestUpdate = false;
  bool _filterExpired = false;
  bool _filterExpSoon = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemProvider.notifier).fetchAllItems());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'List Item Stock',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search item name or code',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.limeGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            // Filter button dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        switch (value) {
                          case 'sort_latest':
                            _sortByLatestUpdate = !_sortByLatestUpdate;
                            break;
                          case 'low_stock':
                            _filterLowStock = !_filterLowStock;
                            break;
                          case 'active':
                            _filterActive = !_filterActive;
                            break;
                          case 'inactive':
                            _filterInactive = !_filterInactive;
                            break;
                          case 'expired':
                            _filterExpired = !_filterExpired;
                            break;
                          case 'exp_soon':
                            _filterExpSoon = !_filterExpSoon;
                            break;
                          case 'reset':
                            _sortByLatestUpdate = false;
                            _filterLowStock = false;
                            _filterActive = true;
                            _filterInactive = true;
                            _filterExpired = false;
                            _filterExpSoon = false;
                            break;
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'sort_latest',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _sortByLatestUpdate,
                              onChanged: null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Latest Updated First'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'low_stock',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _filterLowStock,
                              onChanged: null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Low Stock Only'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'expired',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _filterExpired,
                              onChanged: null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Expired'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'exp_soon',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _filterExpSoon,
                              onChanged: null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Exp Soon (7 Days)'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'active',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _filterActive,
                              onChanged: null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Active Items'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'inactive',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _filterInactive,
                              onChanged: null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Inactive Items'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'reset',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text('Reset Filters'),
                          ],
                        ),
                      ),
                    ],
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list, size: 20, color: AppTheme.darkGreen),
                            SizedBox(width: 6),
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildItemsList(itemState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(ItemState itemState) {
    var filteredItems = itemState.items.where((item) {
      final searchLower = _searchController.text.toLowerCase();
      final nameMatch = item.itemName.toLowerCase().contains(searchLower);
      final codeMatch = item.itemCode.toLowerCase().contains(searchLower);
      return nameMatch || codeMatch;
    }).toList();

    // Apply status filters
    filteredItems = filteredItems.where((item) {
      final isActive = item.status == 'active';
      
      // Check if both filters are false (not filtering by status)
      if (!_filterActive && !_filterInactive) {
        return false;
      }
      
      // If item is active and active filter is on, include it
      if (isActive && _filterActive) {
        return true;
      }
      
      // If item is inactive and inactive filter is on, include it
      if (!isActive && _filterInactive) {
        return true;
      }
      
      return false;
    }).toList();

    // Apply low stock filter
    if (_filterLowStock) {
      filteredItems = filteredItems.where((item) {
        final currentQty = int.tryParse(item.quantity) ?? 0;
        final minQty = int.tryParse(item.minimumStock) ?? 0;
        return currentQty <= minQty;
      }).toList();
    }

    // Apply expired filter
    if (_filterExpired) {
      filteredItems = filteredItems.where((item) {
        return _isExpired(item.expiredDate);
      }).toList();
    }

    // Apply exp soon filter
    if (_filterExpSoon) {
      filteredItems = filteredItems.where((item) {
        return _isExpiringSoon(item.expiredDate);
      }).toList();
    }

    // Sort by latest update if enabled
    if (_sortByLatestUpdate) {
      filteredItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    if (itemState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty ? 'No items found' : 'No items match your search',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(context, item);
      },
    );
  }

  bool _isExpired(String expiredDate) {
    try {
      final expDate = DateFormat('dd/MM/yyyy').parse(expiredDate);
      final today = DateTime.now();
      return expDate.isBefore(DateTime(today.year, today.month, today.day + 1));
    } catch (e) {
      return false;
    }
  }

  bool _isExpiringSoon(String expiredDate) {
    try {
      final expDate = DateFormat('dd/MM/yyyy').parse(expiredDate);
      final today = DateTime.now();
      final difference = expDate.difference(today).inDays;
      return difference > 0 && difference <= 7;
    } catch (e) {
      return false;
    }
  }

  Widget _buildItemCard(BuildContext context, ItemEntity item) {
    final currentQty = int.tryParse(item.quantity) ?? 0;
    final minQty = int.tryParse(item.minimumStock) ?? 0;
    final isLowStock = currentQty <= minQty;
    final isInactive = item.status == 'inactive';
    
    // Check if item is expired - parse from dd/MM/yyyy format
    bool isExpired = false;
    bool willExpire = false;
    DateTime? parsedExpiredDate;
    
    try {
      parsedExpiredDate = DateFormat('dd/MM/yyyy').parse(item.expiredDate);
      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      
      // Check if expired (before today)
      isExpired = parsedExpiredDate.isBefore(DateTime(today.year, today.month, today.day + 1));
      
      // Check if expiring soon (within 7 days)
      final difference = parsedExpiredDate.difference(todayDateOnly).inDays;
      willExpire = difference > 0 && difference <= 7;
    } catch (e) {
      // If parsing fails, just ignore
      isExpired = false;
      willExpire = false;
    }
    
    // Format last updated time
    String getFormattedUpdateTime() {
      final now = DateTime.now();
      final difference = now.difference(item.updatedAt);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with item name and status badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supplier: ${item.supplier}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Low Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Expired',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (willExpire && !isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Exp Soon',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (isInactive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Update time info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last updated: ${getFormattedUpdateTime()}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (parsedExpiredDate != null)
                  Text(
                    'Exp: ${DateFormat('dd/MM/yyyy', 'id_ID').format(parsedExpiredDate)}',
                    style: TextStyle(
                      fontSize: 9,
                      color: isExpired ? Colors.red : (willExpire ? Colors.orange : Colors.grey),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Stock info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Stock',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.quantity} ${item.measure}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Minimum Stock',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.minimumStock} ${item.measure}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Price info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buy Rate',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(double.tryParse(item.buyRate) ?? 0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Sell Rate',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(double.tryParse(item.sellRate) ?? 0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.limeGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons side by side
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDirectUpdateStockDialog(item),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Stock'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brightYellow,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditItemFieldPage(item: item),
                        ),
                      ).then((_) {
                        ref.read(itemProvider.notifier).fetchAllItems();
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.limeGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDirectUpdateStockDialog(ItemEntity item) {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role;

    if (item.status == 'inactive' && userRole != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update stock for inactive items. Please contact administrator.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantityController = TextEditingController(text: item.quantity);
    String? selectedReason;

    const List<String> reasonOptions = [
      'Update Stock',
      'Expired',
      'Demaged/Defective',
      'Lost',
      'Other'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Quantity'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Item: ${item.itemName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Kode: ${item.itemCode}'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Qty Before', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(item.quantity, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('New Qty', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(quantityController.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brightYellow)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'New Quantity',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: 'Enter new quantity',
                    prefixIcon: const Icon(Icons.shopping_cart, color: AppTheme.limeGreen),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Reason for Quantity Change:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedReason,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    hint: const Text('Pilih alasan perubahan', style: TextStyle(fontSize: 13)),
                    items: reasonOptions.map((reason) => DropdownMenuItem(value: reason, child: Text(reason))).toList(),
                    onChanged: (value) => setState(() { selectedReason = value; }),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (quantityController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantity cannot be empty'), backgroundColor: Colors.red));
                  return;
                }
                if (selectedReason == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reasoning of quantity update is required'), backgroundColor: Colors.red));
                  return;
                }

                final now = DateTime.now();
                final updatedBy = authState.user?.email ?? item.updatedBy;
                final updatedItem = ItemEntity(
                  uid: item.uid,
                  itemName: item.itemName,
                  itemCode: item.itemCode,
                  category: item.category,
                  quantity: quantityController.text.trim(),
                  previousQuantity: item.quantity,
                  minimumStock: item.minimumStock,
                  buyRate: item.buyRate,
                  sellRate: item.sellRate,
                  expiredDate: item.expiredDate,
                  measure: item.measure,
                  supplier: item.supplier,
                  description: item.description,
                  imageUrl: item.imageUrl,
                  status: item.status,
                  createdBy: item.createdBy,
                  updatedBy: updatedBy,
                  createdAt: item.createdAt,
                  updatedAt: now,
                  quantityChangeReason: selectedReason,
                );

                try {
                  await ref.read(itemProvider.notifier).updateExistingItem(updatedItem);

                  if (selectedReason != 'Update Stock') {
                    final oldQty = int.tryParse(item.quantity) ?? 0;
                    final newQty = int.tryParse(updatedItem.quantity) ?? 0;
                    final quantityLost = (oldQty - newQty).abs();

                    if (quantityLost > 0) {
                      final createdBy = authState.user?.email ?? 'unknown';
                      final lossRecord = LossRecordModel(
                        uid: '',
                        itemUid: updatedItem.uid,
                        itemName: updatedItem.itemName,
                        itemCode: updatedItem.itemCode,
                        category: 'loss',
                        reasonType: selectedReason!,
                        quantityLost: quantityLost.toString(),
                        buyRate: updatedItem.buyRate,
                        totalLoss: (quantityLost * (double.tryParse(updatedItem.buyRate) ?? 0)).toStringAsFixed(2),
                        createdBy: createdBy,
                        createdAt: DateTime.now(),
                        notes: 'Automatic loss record created from stock update',
                      );

                      final dataSource = LossRecordRemoteDataSource(FirebaseFirestore.instance);
                      await dataSource.createLossRecord(lossRecord as LossRecordEntity);
                    }
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Quantity "${updatedItem.itemName}" successfully updated from ${item.quantity} to ${updatedItem.quantity}', style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.green[700],
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    Navigator.pop(context);
                    ref.read(itemProvider.notifier).fetchAllItems();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating quantity: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Update', style: TextStyle(color: AppTheme.brightYellow)),
            ),
          ],
        ),
      ),
    );
  }
}