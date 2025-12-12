// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../domain/entities/item_entity.dart';
import 'package:vreetory_app/features/inventory/presentation/provider/item_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  @override
  void initState() {
    super.initState();
    _itemNameController.addListener(() {
      if (_itemNameError && _itemNameController.text.isNotEmpty) {
        setState(() {
          _itemNameError = false;
        });
      }
    });
    _buyRateController.addListener(() {
      if (_buyRateError && _buyRateController.text.isNotEmpty) {
        setState(() {
          _buyRateError = false;
        });
      }
    });
    _sellRateController.addListener(() {
      if (_sellRateError && _sellRateController.text.isNotEmpty) {
        setState(() {
          _sellRateError = false;
        });
      }
    });
    _expiredDateController.addListener(() {
      if (_expiredDateError && _expiredDateController.text.isNotEmpty) {
        setState(() {
          _expiredDateError = false;
        });
      }
    });
  }
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _buyRateController = TextEditingController();
  final _sellRateController = TextEditingController();
  final _expiredDateController = TextEditingController();
  final _supplierController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedMeasure;
  bool _status = true;

  // State for label color
  bool _itemNameError = false;
  bool _categoryError = false;
  bool _buyRateError = false;
  bool _sellRateError = false;
  bool _expiredDateError = false;
  bool _measureError = false;

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

    setState(() {
      _itemNameError = _itemNameController.text.trim().isEmpty;
      _categoryError = _selectedCategory == null || _selectedCategory!.isEmpty;
      _buyRateError = _buyRateController.text.trim().isEmpty;
      _sellRateError = _sellRateController.text.trim().isEmpty;
      _expiredDateError = _expiredDateController.text.trim().isEmpty;
      _measureError = _selectedMeasure == null || _selectedMeasure!.isEmpty;
    });

    if (_itemNameError || _categoryError || _buyRateError || _sellRateError || _expiredDateError || _measureError) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Kolom mandatory masih belum terisi, silahkan isi data yang di butuhkan pada kolom'),
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

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menambah item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

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
      previousQuantity: _quantityController.text.trim(), // Set to same as quantity on initial creation
      minimumStock: _minimumStockController.text.trim().isEmpty ? '0' : _minimumStockController.text.trim(),
      buyRate: _buyRateController.text.trim(),
      sellRate: _sellRateController.text.trim(),
      expiredDate: _expiredDateController.text.trim(),
      measure: _selectedMeasure ?? '',
      supplier: _supplierController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: '', // default, no image in form. Will be handled later
      status: _status ? 'active' : 'inactive',
      createdBy: createdBy,
      updatedBy: createdBy,
      createdAt: now,
      updatedAt: now,
      quantityChangeReason: null,
    );
    await itemNotifier.createNewItem(item);
    if (context.mounted && itemState.isSuccess) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Data berhasil dikirim!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemProvider);
    final authState = ref.watch(authProvider);

    if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.user == null) {
      return Scaffold(
        backgroundColor: AppTheme.ivoryWhite,
        appBar: AppBar(
          backgroundColor: const Color(0xFF4B7F52),
          title: const Text('ADD ITEM'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'You must be logged in to add an item.',
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
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
                color: AppTheme.darkGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.limeGreen.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('ITEM NAME', error: _itemNameError),
                    TextFormField(
                      controller: _itemNameController,
                      decoration: _inputDecoration('Enter input here').copyWith(
                        errorText: _itemNameError ? 'Fill the item name' : null,
                      ),
                      validator: (v) => v == null || v.isEmpty ? '' : null,
                    ),
                    _helper('Fill the item name'),
                    const SizedBox(height: 16),
                    _label('ITEM CODE'),
                    TextFormField(
                      controller: _itemCodeController,
                      decoration: _inputDecoration('Enter input here').copyWith(
                        errorText: (_formKey.currentState != null && !_formKey.currentState!.validate() && _itemCodeController.text.isNotEmpty && !RegExp(r'^[a-z0-9]{6}$').hasMatch(_itemCodeController.text))
                            ? 'Item code must be 6 chars, lowercase letters & digits'
                            : null,
                      ),
                      validator: (v) {
                        final value = v ?? '';
                        final regex = RegExp(r'^[a-z0-9]{6}$');
                        if (value.isEmpty) return null; // Will be generated if empty
                        if (!regex.hasMatch(value)) {
                          return '';
                        }
                        return null;
                      },
                    ),
                    _helper('Fill item code (*optional)'),
                    const SizedBox(height: 16),
                    _label('CATEGORY', error: _categoryError),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _inputDecoration('Select input here').copyWith(
                        errorText: _categoryError ? 'Select category' : null,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Food', child: Text('Food')),
                        DropdownMenuItem(value: 'Fruit', child: Text('Fruit')),
                        DropdownMenuItem(value: 'Drink', child: Text('Drink')),
                        DropdownMenuItem(value: 'Vegetable', child: Text('Vegetable')),
                        DropdownMenuItem(value: 'Parcel', child: Text('Parcel')),
                        // Tambahkan opsi lain sesuai kebutuhan
                      ],
                      onChanged: (v) {
                        setState(() {
                          _selectedCategory = v;
                          if (_categoryError && v != null && v.isNotEmpty) {
                            _categoryError = false;
                          }
                        });
                      },
                      validator: (v) => v == null || v.isEmpty ? '' : null,
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
                    _label('MINIMUM STOCK'),
                    TextFormField(
                      controller: _minimumStockController,
                      decoration: _inputDecoration('Enter input here'),
                      keyboardType: TextInputType.number,
                    ),
                    _helper('Fill minimum stock threshold (*optional)'),
                    const SizedBox(height: 16),
                    _label('BUY RATE', error: _buyRateError),
                    TextFormField(
                      controller: _buyRateController,
                      decoration: _inputDecoration('Enter input here').copyWith(
                        errorText: _buyRateError ? 'Fill buy price' : null,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? '' : null,
                    ),
                    _helper('Fill buy price'),
                    const SizedBox(height: 16),
                    _label('SALE RATE', error: _sellRateError),
                    TextFormField(
                      controller: _sellRateController,
                      decoration: _inputDecoration('Enter input here').copyWith(
                        errorText: _sellRateError ? 'Fill sell price' : null,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? '' : null,
                    ),
                    _helper('Fill sell price'),
                    const SizedBox(height: 16),
                    _label('EXPIRED DATE', error: _expiredDateError),
                    TextFormField(
                      controller: _expiredDateController,
                      decoration: _inputDecoration('DD/MM/YYYY').copyWith(
                        errorText: _expiredDateError ? 'Select date of item expired' : null,
                      ),
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
                          if (_expiredDateError) {
                            setState(() {
                              _expiredDateError = false;
                            });
                          }
                        }
                      },
                      validator: (v) => v == null || v.isEmpty ? '' : null,
                    ),
                    _helper('Select date of item expired'),
                    const SizedBox(height: 16),
                    _label('MEASURE', error: _measureError),
                    DropdownButtonFormField<String>(
                      value: _selectedMeasure,
                      decoration: _inputDecoration('Enter input here').copyWith(
                        errorText: _measureError ? 'Select measure' : null,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'PCS', child: Text('PCS')),
                        DropdownMenuItem(value: 'KG', child: Text('KG')),
                        DropdownMenuItem(value: 'ML', child: Text('ML')),
                        DropdownMenuItem(value: 'LITER', child: Text('LITER')),
                        DropdownMenuItem(value: 'BOX', child: Text('BOX')),
                        // Tambahkan opsi lain sesuai kebutuhan
                      ],
                      onChanged: (v) {
                        setState(() {
                          _selectedMeasure = v;
                          if (_measureError && v != null && v.isNotEmpty) {
                            _measureError = false;
                          }
                        });
                      },
                      validator: (v) => v == null || v.isEmpty ? '' : null,
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
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedOutlinedButton(
                        label: 'SUBMIT DATA',
                        borderColor: AppTheme.brightYellow,
                        textColor: AppTheme.brightYellow,
                        onPressed: itemState.isLoading
                            ? () {}
                            : () async {
                                final authState = ref.read(authProvider);
                                final createdBy = authState.user?.email ?? '';
                                if (createdBy.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You must be logged in to add an item.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                await handleSubmit();
                              },
                      ),
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

  Widget _label(String text, {bool error = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            color: error ? Colors.red : AppTheme.brightYellow,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _helper(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 2),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
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