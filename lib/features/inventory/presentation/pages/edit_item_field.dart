// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../domain/entities/item_entity.dart';
import '../provider/item_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class EditItemFieldPage extends ConsumerStatefulWidget {
  final ItemEntity item;
  const EditItemFieldPage({super.key, required this.item});

  @override
  ConsumerState<EditItemFieldPage> createState() => _EditItemFieldPageState();
}

class _EditItemFieldPageState extends ConsumerState<EditItemFieldPage> {
  late final TextEditingController _itemNameController;
  late final TextEditingController _itemCodeController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minimumStockController;
  late final TextEditingController _buyRateController;
  late final TextEditingController _sellRateController;
  late final TextEditingController _expiredDateController;
  late final TextEditingController _supplierController;
  late final TextEditingController _descriptionController;

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

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _itemNameController = TextEditingController(text: item.itemName);
    _itemCodeController = TextEditingController(text: item.itemCode);
    _quantityController = TextEditingController(text: item.quantity);
    _minimumStockController = TextEditingController(text: item.minimumStock);
    _buyRateController = TextEditingController(text: item.buyRate);
    _sellRateController = TextEditingController(text: item.sellRate);
    _expiredDateController = TextEditingController(text: item.expiredDate);
    _supplierController = TextEditingController(text: item.supplier);
    _descriptionController = TextEditingController(text: item.description);
    _selectedCategory = item.category;
    _selectedMeasure = item.measure;
    _status = item.status == 'active';
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCodeController.dispose();
    _quantityController.dispose();
    _minimumStockController.dispose();
    _buyRateController.dispose();
    _sellRateController.dispose();
    _expiredDateController.dispose();
    _supplierController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> handleUpdate() async {
    final itemNotifier = ref.read(itemProvider.notifier);

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
          title: const Text('Kolom Mandatory Belum Terisi'),
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
        content: const Text('Apakah Anda yakin ingin mengupdate item ini?'),
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
    final authState = ref.read(authProvider);
    
    // Check if user is trying to update quantity on inactive item (only admin can do this)
    final quantityChanged = _quantityController.text.trim() != widget.item.quantity;
    if (authState.user?.role == 'user' && widget.item.status == 'inactive' && quantityChanged) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Akses Ditolak'),
          content: const Text('User tidak memiliki izin untuk mengubah quantity item yang inactive. Hanya admin yang dapat mengubah quantity item inactive.'),
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
    
    // Check if user is trying to change status (only admin can change status)
    if (authState.user?.role == 'user' && _status != (widget.item.status == 'active')) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Akses Ditolak'),
          content: const Text('User tidak memiliki izin untuk mengubah status item. Hanya admin yang dapat mengubah status.'),
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
    
    final updatedBy = authState.user?.email ?? widget.item.updatedBy;
    
    final updatedItem = ItemEntity(
      uid: widget.item.uid,
      itemName: _itemNameController.text.trim(),
      itemCode: _itemCodeController.text.trim(),
      category: _selectedCategory ?? '',
      quantity: _quantityController.text.trim(),
      previousQuantity: quantityChanged ? widget.item.quantity : widget.item.previousQuantity,
      minimumStock: _minimumStockController.text.trim().isEmpty ? '0' : _minimumStockController.text.trim(),
      buyRate: _buyRateController.text.trim(),
      sellRate: _sellRateController.text.trim(),
      expiredDate: _expiredDateController.text.trim(),
      measure: _selectedMeasure ?? '',
      supplier: _supplierController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: widget.item.imageUrl,
      status: _status ? 'active' : 'inactive',
      createdBy: widget.item.createdBy,
      updatedBy: updatedBy,
      createdAt: widget.item.createdAt,
      updatedAt: now,
      quantityChangeReason: widget.item.quantityChangeReason,
    );
    await itemNotifier.updateExistingItem(updatedItem);
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Data berhasil diupdate!'),
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
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role;
    final isItemInactive = widget.item.status == 'inactive';
    final canUserEdit = userRole == 'admin' || (userRole == 'user' && !isItemInactive);

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        title: const Text('EDIT ITEM FIELD'),
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
              child: canUserEdit
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label('ITEM NAME', error: _itemNameError),
                  TextFormField(
                    controller: _itemNameController,
                    decoration: _inputDecoration('Enter input here'),
                  ),
                  _helper('Fill the item name'),
                  const SizedBox(height: 16),
                  _label('ITEM CODE'),
                  TextFormField(
                    controller: _itemCodeController,
                    decoration: _inputDecoration('Enter input here'),
                  ),
                  _helper('Fill item code (*optional)'),
                  const SizedBox(height: 16),
                  _label('CATEGORY', error: _categoryError),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: _inputDecoration('Select input here'),
                    items: const [
                      DropdownMenuItem(value: 'Food', child: Text('Food')),
                      DropdownMenuItem(value: 'Fruit', child: Text('Fruit')),
                      DropdownMenuItem(value: 'Drink', child: Text('Drink')),
                      DropdownMenuItem(value: 'Vegetable', child: Text('Vegetable')),
                      DropdownMenuItem(value: 'Parcel', child: Text('Parcel')),
                      // Tambahkan opsi lain sesuai kebutuhan
                    ],
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                  _helper('Select category'),
                  const SizedBox(height: 16),
                  _label('QUANTITY'),
                  TextFormField(
                    controller: _quantityController,
                    decoration: _inputDecoration('Enter input here'),
                    keyboardType: TextInputType.number,
                    enabled: canUserEdit,
                    onChanged: canUserEdit ? null : (_) {},
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
                    decoration: _inputDecoration('Enter input here'),
                    keyboardType: TextInputType.number,
                  ),
                  _helper('Fill buy price'),
                  const SizedBox(height: 16),
                  _label('SALE RATE', error: _sellRateError),
                  TextFormField(
                    controller: _sellRateController,
                    decoration: _inputDecoration('Enter input here'),
                    keyboardType: TextInputType.number,
                  ),
                  _helper('Fill sell price'),
                  const SizedBox(height: 16),
                  _label('EXPIRED DATE', error: _expiredDateError),
                  TextFormField(
                    controller: _expiredDateController,
                    decoration: _inputDecoration('DD/MM/YYYY'),
                    readOnly: true,
                    onTap: () async {
                      // Parse current date or use today if invalid
                      DateTime initialDate = DateTime.now();
                      try {
                        initialDate = DateFormat('dd/MM/yyyy').parse(_expiredDateController.text.trim());
                      } catch (e) {
                        initialDate = DateTime.now();
                      }
                      
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _expiredDateController.text = DateFormat('dd/MM/yyyy').format(picked);
                      }
                    },
                  ),
                  _helper('Select date of item expired'),
                  const SizedBox(height: 16),
                  _label('MEASURE', error: _measureError),
                  DropdownButtonFormField<String>(
                    value: _selectedMeasure,
                    decoration: _inputDecoration('Enter input here'),
                    items: const [
                      DropdownMenuItem(value: 'PCS', child: Text('PCS')),
                      DropdownMenuItem(value: 'KG', child: Text('KG')),
                      DropdownMenuItem(value: 'ML', child: Text('ML')),
                      DropdownMenuItem(value: 'LITER', child: Text('LITER')),
                      DropdownMenuItem(value: 'BOX', child: Text('BOX')),
                      // Tambahkan opsi lain sesuai kebutuhan
                    ],
                    onChanged: (v) => setState(() => _selectedMeasure = v),
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
                  _buildStatusSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedOutlinedButton(
                      label: 'UPDATE DATA',
                      borderColor: AppTheme.brightYellow,
                      textColor: AppTheme.brightYellow,
                      onPressed: handleUpdate,
                    ),
                  ),
                ]
                  )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 64,
                          color: Colors.red[800],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Access Denied',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Items with INACTIVE status cannot be modified by regular users.\n\nContact the administrator to activate this item.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedOutlinedButton(
                            label: 'BACK',
                            borderColor: AppTheme.brightYellow,
                            textColor: AppTheme.brightYellow,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
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

  Widget _buildStatusSection() {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role;
    final isAdmin = userRole == 'admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('STATUS'),
        if (isAdmin)
          CheckboxListTile(
            value: _status,
            onChanged: (v) => setState(() => _status = v ?? true),
            title: const Text('Check for active status item or uncheck for inactive status item', style: TextStyle(color: Colors.white)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _status ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      color: _status ? AppTheme.limeGreen : Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  _status ? Icons.check_circle : Icons.cancel,
                  color: _status ? AppTheme.limeGreen : Colors.red[800],
                ),
              ],
            ),
          ),
        _helper(isAdmin ? 'Check for active status item or uncheck for inactive status item' : 'Status item (User tidak dapat mengubah status)'),
      ],
    );
  }

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