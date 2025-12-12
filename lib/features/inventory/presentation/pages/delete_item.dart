// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../domain/entities/item_entity.dart';
import '../provider/item_provider.dart';

class DeleteItemPage extends ConsumerStatefulWidget {
  const DeleteItemPage({super.key});

  @override
  ConsumerState<DeleteItemPage> createState() => _DeleteItemPageState();
}

class _DeleteItemPageState extends ConsumerState<DeleteItemPage> {
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

  Future<void> _showDeleteConfirmation(BuildContext context, ItemEntity item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Delete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus item ini?'),
            const SizedBox(height: 16),
            Text(
              'Item: ${item.itemName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Kode: ${item.itemCode}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _handleDeleteItem(item);
    }
  }

  Future<void> _handleDeleteItem(ItemEntity item) async {
    try {
      await ref.read(itemProvider.notifier).deleteExistingItem(item.uid);

      // Show success notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item "${item.itemName}" berhasil dihapus',
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
              'Gagal menghapus item: ${e.toString()}',
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
        title: const Text('DELETE ITEM'),
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
                  prefixIcon: const Icon(Icons.search, color: AppTheme.limeGreen),
                  filled: true,
                  fillColor: AppTheme.cleanWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppTheme.brightYellow, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppTheme.limeGreen, width: 2),
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
                            'Tidak ada item',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              color: Colors.red[50],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                title: Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkGray,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (item.status).toUpperCase(),
                                      style: TextStyle(
                                        color: item.status == 'active'
                                            ? AppTheme.limeGreen
                                            : Colors.red[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Updated: ${DateFormat('dd/MM/yyyy HH:mm').format(item.updatedAt)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 40,
                                          child: AnimatedOutlinedButton(
                                            label: 'DELETE',
                                            borderColor: Colors.red[700] ?? Colors.red,
                                            textColor: Colors.red[700] ?? Colors.red,
                                            onPressed: () => _showDeleteConfirmation(context, item),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
}