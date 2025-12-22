// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../domain/entities/item_entity.dart';
import '../provider/item_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../reporting/data/models/loss_record_model.dart';
import '../../../reporting/data/datasources/loss_record_remote_datasource.dart';
import '../../../reporting/domain/entities/loss_record_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateStockPage extends ConsumerStatefulWidget {
  const UpdateStockPage({super.key});

  @override
  ConsumerState<UpdateStockPage> createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends ConsumerState<UpdateStockPage> {
  final TextEditingController _searchController = TextEditingController();

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

  void _showUpdateQuantityDialog(BuildContext context, ItemEntity item) {
    // Check role-based access for inactive items
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role;

    if (item.status == 'inactive' && userRole != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cannot update stock for inactive items. Please contact administrator.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantityController = TextEditingController(text: item.quantity);
    String? selectedReason;

    // Define possible reasons for quantity change
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
                Text(
                  'Item: ${item.itemName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
                            const Text('Qty Before',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(item.previousQuantity,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward,
                          color: Colors.grey[400], size: 20),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('New Qty',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(quantityController.text,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.brightYellow)),
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
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'New Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Enter new quantity',
                    prefixIcon: const Icon(Icons.shopping_cart,
                        color: AppTheme.limeGreen),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reason for Quantity Change:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
                    hint: const Text('Select a reason',
                        style: TextStyle(fontSize: 13)),
                    items: reasonOptions.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (quantityController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quantity cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (selectedReason == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reasoning of quantity update is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final now = DateTime.now();
                final authState = ref.read(authProvider);
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

                await _handleUpdateQuantity(
                    context, updatedItem, item.quantity);
                Navigator.pop(context);
              },
              child: const Text(
                'Update',
                style: TextStyle(color: AppTheme.brightYellow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdateQuantity(
    BuildContext context,
    ItemEntity updatedItem,
    String oldQuantity,
  ) async {
    try {
      // Update the item quantity
      await ref.read(itemProvider.notifier).updateExistingItem(updatedItem);

      // Create loss record only for specific loss-related reasons
      // 'Update Stock' and 'Other' are treated as adjustments, not losses
      if (updatedItem.quantityChangeReason != null &&
          ['Expired', 'Demaged/Defective', 'Lost']
              .contains(updatedItem.quantityChangeReason)) {
        final oldQty = double.tryParse(oldQuantity) ?? 0.0;
        final newQty = double.tryParse(updatedItem.quantity) ?? 0.0;
        final quantityLost = (oldQty - newQty).abs();

        if (quantityLost > 0) {
          final authState = ref.read(authProvider);
          final createdBy = authState.user?.email ?? 'unknown';

          final lossRecord = LossRecordModel(
            uid: '', // Let Firestore generate the ID
            itemUid: updatedItem.uid,
            itemName: updatedItem.itemName,
            itemCode: updatedItem.itemCode,
            category: 'loss',
            reasonType: updatedItem.quantityChangeReason!,
            quantityLost: quantityLost.toString(),
            buyRate: updatedItem.buyRate,
            totalLoss:
                (quantityLost * (double.tryParse(updatedItem.buyRate) ?? 0))
                    .toStringAsFixed(2),
            createdBy: createdBy,
            createdAt: DateTime.now(),
            notes: 'Automatic loss record created from stock update',
          );

          // Save loss record to database
          final dataSource =
              LossRecordRemoteDataSource(FirebaseFirestore.instance);
          await dataSource.createLossRecord(lossRecord as LossRecordEntity);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quantity "${updatedItem.itemName}" has been updated from $oldQuantity to ${updatedItem.quantity}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update quantity: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemProvider);
    final items = List.of(itemState.items)
      ..sort((a, b) {
        final aDate = a.updatedAt;
        final bDate = b.updatedAt;
        return bDate.compareTo(aDate);
      });

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        title: const Text('UPDATE STOCK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(itemProvider.notifier).searchItems(value);
                },
                decoration: InputDecoration(
                  hintText: 'SEARCH',
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.limeGreen),
                  filled: true,
                  fillColor: AppTheme.cleanWhite,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: AppTheme.brightYellow, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: AppTheme.limeGreen, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: itemState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(
                          child: Text(
                            'Item not found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              color: AppTheme.brightYellow,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.itemName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.darkGray,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Code: ${item.itemCode}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.darkGreen,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Quantity',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                item.quantity,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.brightYellow,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Status',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                (item.status).toUpperCase(),
                                                style: TextStyle(
                                                  color: item.status == 'active'
                                                      ? AppTheme.limeGreen
                                                      : Colors.red[800],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Last Updated',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat('dd/MM/yyyy\nHH:mm')
                                                    .format(item.updatedAt),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildUpdateButton(context, item, ref),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(
      BuildContext context, ItemEntity item, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role;
    final isItemInactive = item.status == 'inactive';
    final canUserUpdate =
        userRole == 'admin' || (userRole == 'user' && !isItemInactive);

    if (!canUserUpdate) {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Item Inactive - Update Stock Disabled',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: AnimatedOutlinedButton(
        label: 'UPDATE QUANTITY',
        borderColor: AppTheme.darkGray,
        textColor: AppTheme.darkGray,
        onPressed: () => _showUpdateQuantityDialog(context, item),
      ),
    );
  }
}
