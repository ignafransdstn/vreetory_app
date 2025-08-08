import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/item_entity.dart';
import 'package:vreetory_app/features/inventory/presentation/provider/item_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _buyRateController = TextEditingController();
  final _sellRateController = TextEditingController();
  final _expiredDateController = TextEditingController();
  final _supplierController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedMeasure;
  bool _status = true;

  String generateRandomCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(6, (index) {
      final rand = DateTime.now().millisecondsSinceEpoch + index * 17;
      return chars[(rand % chars.length)];
    }).join();
  }

  Future<void> handleSubmit() async {
    final itemState = ref.read(itemProvider);
    final itemNotifier = ref.read(itemProvider.notifier);
    final authState = ref.read(authProvider);

    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      final createdBy = authState.user?.email ?? '';
      String itemCode = _itemCodeController.text.trim();
      if (itemCode.isEmpty) {
        itemCode = generateRandomCode();
      }
      final item = ItemEntity(
        uid: '', // UID akan di-generate oleh Firestore, leave empty here
        itemName: _itemNameController.text.trim(),
        itemCode: itemCode,
        category: _selectedCategory ?? '',
        quantity: _quantityController.text.trim(),
        buyRate: _buyRateController.text.trim(),
        sellRate: _sellRateController.text.trim(),
        expiredDate: _expiredDateController.text.trim(),
        measure: _selectedMeasure ?? '',
        supplier: _supplierController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: '', // default, no image in form
        status: _status ? 'active' : 'inactive',
        createdBy: createdBy,
        createdAt: now,
        updatedAt: now,
      );
      await itemNotifier.createNewItem(item);
      if (context.mounted && itemState.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item created successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemProvider);
    final itemNotifier = ref.read(itemProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFD6FFB7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B7F52),
        title: const Text('ADD ITEM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(24),
              width: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF27632A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('ITEM NAME'),
                    TextFormField(
                      controller: _itemNameController,
                      decoration: _inputDecoration('Enter input here'),
                      validator: (v) => v == null || v.isEmpty ? 'Fill the item name' : null,
                    ),
                    _helper('Fill the item name'),
                    const SizedBox(height: 16),
                    _label('ITEM CODE'),
                    TextFormField(
                      controller: _itemCodeController,
                      decoration: _inputDecoration('Enter input here'),
                      validator: (v) {
                        final value = v ?? '';
                        final regex = RegExp(r'^[a-z0-9]{6}$');
                        if (value.isEmpty) return null; // Will be generated if empty
                        if (!regex.hasMatch(value)) {
                          return 'Item code must be 6 chars, lowercase letters & digits';
                        }
                        return null;
                      },
                    ),
                    _helper('Fill item code (*optional)'),
                    const SizedBox(height: 16),
                    _label('CATEGORY'),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _inputDecoration('Select input here'),
                      items: const [
                        DropdownMenuItem(value: 'Category1', child: Text('Category1')),
                        DropdownMenuItem(value: 'Category2', child: Text('Category2')),
                        // Tambahkan opsi lain sesuai kebutuhan
                      ],
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      validator: (v) => v == null || v.isEmpty ? 'Select category' : null,
                    ),
                    _helper('Select category'),
                    const SizedBox(height: 16),
                    _label('QUANTITY'),
                    TextFormField(
                      controller: _quantityController,
                      decoration: _inputDecoration('Enter input here'),
                      keyboardType: TextInputType.number,
                    ),
                    _helper('Fill quantity (*optional)'),
                    const SizedBox(height: 16),
                    _label('BUY RATE'),
                    TextFormField(
                      controller: _buyRateController,
                      decoration: _inputDecoration('Enter input here'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Fill buy price' : null,
                    ),
                    _helper('Fill buy price'),
                    const SizedBox(height: 16),
                    _label('SALE RATE'),
                    TextFormField(
                      controller: _sellRateController,
                      decoration: _inputDecoration('Enter input here'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Fill sell price' : null,
                    ),
                    _helper('Fill sell price'),
                    const SizedBox(height: 16),
                    _label('EXPIRED DATE'),
                    TextFormField(
                      controller: _expiredDateController,
                      decoration: _inputDecoration('DD/MM/YYYY'),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _expiredDateController.text = DateFormat('dd/MM/yyyy').format(picked);
                        }
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Select date of item expired' : null,
                    ),
                    _helper('Select date of item expired'),
                    const SizedBox(height: 16),
                    _label('MEASURE'),
                    DropdownButtonFormField<String>(
                      value: _selectedMeasure,
                      decoration: _inputDecoration('Enter input here'),
                      items: const [
                        DropdownMenuItem(value: 'Measure1', child: Text('Measure1')),
                        DropdownMenuItem(value: 'Measure2', child: Text('Measure2')),
                        // Tambahkan opsi lain sesuai kebutuhan
                      ],
                      onChanged: (v) => setState(() => _selectedMeasure = v),
                      validator: (v) => v == null || v.isEmpty ? 'Select measure' : null,
                    ),
                    _helper('Select measure'),
                    const SizedBox(height: 16),
                    _label('SUPPLIER'),
                    TextFormField(
                      controller: _supplierController,
                      decoration: _inputDecoration('Enter input here'),
                    ),
                    _helper('Fill supplier name (*optional)'),
                    const SizedBox(height: 16),
                    _label('ITEM DESCRIPTION'),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('Enter input here'),
                      maxLines: 3,
                    ),
                    _helper('Fill item description (*optional)'),
                    const SizedBox(height: 16),
                    _label('STATUS'),
                    CheckboxListTile(
                      value: _status,
                      onChanged: (v) => setState(() => _status = v ?? true),
                      title: const Text('Check for active status item or uncheck for inactive status item', style: TextStyle(color: Colors.white)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD600),
                        foregroundColor: Colors.black,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: itemState.isLoading
                          ? null
                          : handleSubmit,
                      child: itemState.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('SUBMIT DATA'),
                    ),
                    if (itemState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          itemState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      );

  Widget _helper(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}