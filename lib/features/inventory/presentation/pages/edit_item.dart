import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item_entity.dart';
import '../provider/item_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import 'edit_item_field.dart';

class EditItemPage extends ConsumerStatefulWidget {
  const EditItemPage({super.key});

  @override
  ConsumerState<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends ConsumerState<EditItemPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemProvider.notifier).fetchAllItems());
  }

  void _handleEditItemTap(BuildContext context, ItemEntity item) {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role;
    final isItemInactive = item.status == 'inactive';
    
    // Check if user is trying to edit an inactive item
    if (userRole == 'user' && isItemInactive) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Access Denied'),
          content: const Text('Users cannot modify items with INACTIVE status. Contact the administrator to activate this item.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    // Open edit item page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditItemFieldPage(item: item),
      ),
    );
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
        title: const Text('EDIT ITEM'),
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
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          color: AppTheme.brightYellow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            onTap: () => _handleEditItemTap(context, item),
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
                            trailing: const Icon(Icons.edit, color: AppTheme.limeGreen),
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