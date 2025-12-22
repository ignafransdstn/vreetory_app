import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vreetory_app/core/theme/app_theme.dart';
import 'package:vreetory_app/core/utils/quantity_formatter.dart';
import 'package:vreetory_app/features/inventory/domain/entities/item_entity.dart';
import 'package:vreetory_app/features/inventory/presentation/provider/item_provider.dart';
import 'package:vreetory_app/features/pos/presentation/providers/cart_provider.dart';
import 'package:vreetory_app/features/pos/presentation/providers/cashier_session_provider.dart';
import 'package:vreetory_app/features/pos/domain/entities/cart_item.dart';
import 'package:vreetory_app/features/pos/domain/entities/cart_state.dart';
import 'package:vreetory_app/features/pos/presentation/widgets/payment_dialog.dart';

class CashierPage extends ConsumerStatefulWidget {
  const CashierPage({super.key});

  @override
  ConsumerState<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends ConsumerState<CashierPage> {
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(itemProvider.notifier).fetchAllItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ItemEntity> _filterItems(List<ItemEntity> items) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      return item.itemName.toLowerCase().contains(query) ||
          item.itemCode.toLowerCase().contains(query);
    }).toList();
  }

  void _addToCart(ItemEntity item) {
    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.addToCart(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.itemName} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.leafGreen,
      ),
    );
  }

  void _showCheckoutDialog() {
    final cartState = ref.read(cartProvider);

    if (cartState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(
        totalAmount: cartState.total,
      ),
    ).then((success) {
      if (success == true) {
        // Refresh item list after successful transaction
        ref.read(itemProvider.notifier).fetchAllItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemProvider);
    final cartState = ref.watch(cartProvider);
    final cashierSession = ref.watch(currentCashierProvider);
    final isApprovedCashier = ref.watch(isApprovedCashierProvider);

    // Check if user is approved to use cashier
    if (!isApprovedCashier) {
      return Scaffold(
        backgroundColor: AppTheme.ivoryWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Akses Kasir Tidak Tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda tidak memiliki izin untuk mengakses halaman kasir',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Cashier Info and Cart Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cashier Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Point of Sale',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        Text(
                          cashierSession?.name ?? 'Kasir',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.leafGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cart Button
                  if (!isTablet)
                    ElevatedButton.icon(
                      onPressed: () => _showCartBottomSheet(cartState),
                      icon: const Icon(Icons.shopping_cart, size: 20),
                      label: Text('${cartState.items.length}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.leafGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.citrusOrange),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.leafGreen, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            // Main Content Area
            Expanded(
              child: isTablet
                  ? Row(
                      children: [
                        // Product Grid (Left)
                        Expanded(
                          flex: 2,
                          child: _buildProductSection(itemState),
                        ),
                        // Cart Panel (Right)
                        SizedBox(
                          width: 340,
                          child: _buildCartPanel(cartState),
                        ),
                      ],
                    )
                  : _buildProductSection(itemState),
            ),

            // Bottom Checkout Bar (Mobile only)
            if (!isTablet && cartState.items.isNotEmpty)
              _buildBottomCheckoutBar(cartState),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(itemState) {
    final filteredItems = _filterItems(itemState.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Daftar Produk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.leafGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredItems.length} item',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.leafGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Product Grid
        Expanded(
          child: itemState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProductGrid(filteredItems),
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutBar(CartState cartState) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch cart state for real-time updates
        final currentCartState = ref.watch(cartProvider);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total (${currentCartState.items.length} item)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _currencyFormat.format(currentCartState.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.leafGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _showCheckoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.citrusOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCartBottomSheet(CartState cartState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Cart Content
              Expanded(
                child: _buildCartPanel(cartState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<ItemEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Belum ada produk'
                  : 'Produk tidak ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.70,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isActive = item.status.toLowerCase() == 'active';
        final quantity = double.tryParse(item.quantity) ?? 0.0;
        final isOutOfStock = quantity <= 0;
        final price = double.tryParse(item.sellRate) ?? 0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutOfStock || !isActive
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: (isActive && !isOutOfStock) ? () => _addToCart(item) : null,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Image
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: item.imageUrl.isNotEmpty
                            ? Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                    ),
                    // Product Info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Product Name
                            Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isOutOfStock || !isActive
                                    ? Colors.grey
                                    : AppTheme.darkGray,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Price
                            Text(
                              _currencyFormat.format(price),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isOutOfStock || !isActive
                                    ? Colors.grey
                                    : AppTheme.leafGreen,
                              ),
                            ),
                            const Spacer(),
                            // Stock Info
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isOutOfStock
                                    ? Colors.red[50]
                                    : quantity < 10
                                        ? Colors.orange[50]
                                        : AppTheme.leafGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isOutOfStock
                                    ? 'Habis'
                                    : 'Stok: ${QuantityFormatter.formatWithMeasure(item.quantity, item.measure)}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isOutOfStock
                                      ? Colors.red[700]
                                      : quantity < 10
                                          ? Colors.orange[700]
                                          : AppTheme.leafGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Add Icon
                if (isActive && !isOutOfStock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.citrusOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartPanel(CartState cartState) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch cart state for real-time updates
        final currentCartState = ref.watch(cartProvider);

        return Column(
          children: [
            // Cart Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.leafGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Keranjang (${currentCartState.items.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (currentCartState.items.isNotEmpty)
                    IconButton(
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Kosongkan Keranjang'),
                            content: const Text(
                                'Apakah Anda yakin ingin mengosongkan keranjang?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(cartProvider.notifier).clearCart();
                                  Navigator.pop(context);
                                },
                                child: const Text('Kosongkan'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // Cart Items
            Expanded(
              child: currentCartState.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Keranjang Kosong',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: currentCartState.items.length,
                      itemBuilder: (context, index) {
                        final cartItem = currentCartState.items[index];
                        return _buildCartItem(cartItem);
                      },
                    ),
            ),

            // Cart Summary
            if (currentCartState.items.isNotEmpty)
              _buildCartSummary(currentCartState),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(CartItem cartItem) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch cart state to get fresh quantity
        final cartState = ref.watch(cartProvider);
        final currentItem = cartState.items.firstWhere(
          (item) => item.itemId == cartItem.itemId,
          orElse: () => cartItem,
        );

        final price = double.parse(currentItem.unitPrice);
        final quantity = double.parse(currentItem.quantity);
        final subtotal = price * quantity;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Name
                Text(
                  currentItem.itemName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  _currencyFormat.format(price),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),

                // Quantity Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuantityEditor(itemId: currentItem.itemId),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        ref
                            .read(cartProvider.notifier)
                            .removeItem(currentItem.itemId);
                      },
                      color: Colors.red,
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Subtotal
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _currencyFormat.format(subtotal),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.citrusOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartSummary(CartState cartState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer(
      builder: (context, ref, child) {
        // Watch cart state for real-time updates
        final currentCartState = ref.watch(cartProvider);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal:',
                    style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
                  ),
                  Text(
                    _currencyFormat.format(currentCartState.subtotal),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),

              // Discount
              if (currentCartState.discount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Diskon:',
                      style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
                    ),
                    Text(
                      '-${_currencyFormat.format(currentCartState.discount)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],

              // Tax
              if (currentCartState.tax > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pajak:',
                      style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
                    ),
                    Text(
                      _currencyFormat.format(currentCartState.tax),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ],

              const Divider(height: 24, thickness: 1.5),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  Text(
                    _currencyFormat.format(currentCartState.total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.citrusOrange,
                    ),
                  ),
                ],
              ),

              // Checkout Button (Only for Tablet/Desktop)
              if (isTablet) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showCheckoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.citrusOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'CHECKOUT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Stateful widget for editable quantity control
class _QuantityEditor extends ConsumerStatefulWidget {
  final String itemId;

  const _QuantityEditor({required this.itemId});

  @override
  ConsumerState<_QuantityEditor> createState() => _QuantityEditorState();
}

class _QuantityEditorState extends ConsumerState<_QuantityEditor> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode!.addListener(() {
      setState(() {
        _isEditing = _focusNode!.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  void _updateQuantity(double newQuantity) {
    if (newQuantity > 0) {
      ref
          .read(cartProvider.notifier)
          .updateQuantity(widget.itemId, newQuantity);
    } else {
      ref.read(cartProvider.notifier).removeItem(widget.itemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch cart state to get current quantity
    final cartState = ref.watch(cartProvider);
    final cartItem = cartState.items.firstWhere(
      (item) => item.itemId == widget.itemId,
      orElse: () => CartItem(
        itemId: widget.itemId,
        itemCode: '',
        itemName: '',
        category: '',
        measure: '',
        quantity: '0',
        availableStock: '0',
        buyRate: '0',
        sellRate: '0',
        unitPrice: '0',
        subtotal: '0',
        profit: '0',
        imageUrl: '',
        addedAt: DateTime.now(),
      ),
    );
    final currentQuantity = cartItem.quantity;
    final measure = cartItem.measure.toUpperCase();

    // Check if measure allows decimal values
    final allowDecimal =
        measure == 'KG' || measure == 'LITER' || measure == 'L';

    // Update controller text if not editing
    if (!_isEditing) {
      _controller?.dispose();
      _controller = TextEditingController(text: currentQuantity);
    }

    return Row(
      children: [
        // Decrement Button
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.citrusOrange),
            borderRadius: BorderRadius.circular(6),
          ),
          child: InkWell(
            onTap: () {
              final currentQty = double.tryParse(currentQuantity) ?? 1.0;
              final decrement = allowDecimal ? 0.5 : 1.0;
              _updateQuantity(currentQty - decrement);
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.remove,
                color: AppTheme.citrusOrange,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Editable Quantity
        Container(
          width: 50,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType: allowDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            inputFormatters: allowDecimal
                ? [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ]
                : [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              isDense: true,
            ),
            onSubmitted: (value) {
              final newQuantity = double.tryParse(value) ?? 1.0;
              _updateQuantity(newQuantity);
              _focusNode?.unfocus();
            },
            onTapOutside: (event) {
              _focusNode?.unfocus();
            },
          ),
        ),
        const SizedBox(width: 8),
        // Increment Button
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.leafGreen),
            borderRadius: BorderRadius.circular(6),
          ),
          child: InkWell(
            onTap: () {
              final currentQty = double.tryParse(currentQuantity) ?? 1.0;
              final increment = allowDecimal ? 0.5 : 1.0;
              _updateQuantity(currentQty + increment);
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.add,
                color: AppTheme.leafGreen,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
