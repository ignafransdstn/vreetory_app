import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/item_provider.dart';
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
      backgroundColor: const Color(0xFFD6FFB7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B7F52),
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
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
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
                          color: const Color(0xFFFFD93D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditItemFieldPage(item: item),
                                ),
                              );
                            },
                            title: Text(
                              item.itemName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B7F52),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (item.status ?? '').toUpperCase(),
                                  style: TextStyle(
                                    color: item.status == 'active'
                                        ? Colors.green[800]
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
                            trailing: const Icon(Icons.edit, color: Color(0xFF4B7F52)),
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