import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vreetory_app/core/theme/app_theme.dart';
import 'package:vreetory_app/features/pos/presentation/providers/transaction_provider.dart';
import 'package:vreetory_app/features/pos/presentation/providers/cart_provider.dart';
import 'package:vreetory_app/features/pos/presentation/widgets/receipt_widget.dart';

/// Payment Dialog for checkout process
class PaymentDialog extends ConsumerStatefulWidget {
  final double totalAmount;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
  });

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _selectedPaymentMethod = 'cash';
  double _amountPaid = 0;
  double _change = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Set initial amount for cash payment
    if (_selectedPaymentMethod == 'cash') {
      _amountController.text = widget.totalAmount.toStringAsFixed(0);
      _amountPaid = widget.totalAmount;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onPaymentMethodChanged(String method) {
    setState(() {
      _selectedPaymentMethod = method;

      if (method == 'cash') {
        // For cash, allow custom amount
        _amountController.text = widget.totalAmount.toStringAsFixed(0);
        _amountPaid = widget.totalAmount;
        _calculateChange();
      } else {
        // For non-cash, amount paid = total (exact payment)
        _amountController.text = widget.totalAmount.toStringAsFixed(0);
        _amountPaid = widget.totalAmount;
        _change = 0;
      }
    });
  }

  void _onAmountChanged(String value) {
    final amount =
        double.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    setState(() {
      _amountPaid = amount;
      _calculateChange();
    });
  }

  void _calculateChange() {
    if (_selectedPaymentMethod == 'cash') {
      _change = _amountPaid - widget.totalAmount;
    } else {
      _change = 0;
    }
  }

  void _setSuggestedAmount(double amount) {
    setState(() {
      _amountPaid = amount;
      _amountController.text = amount.toStringAsFixed(0);
      _calculateChange();
    });
  }

  Future<void> _processCheckout() async {
    // Validation
    if (_selectedPaymentMethod == 'cash' && _amountPaid < widget.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah pembayaran kurang dari total'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final transactionNotifier = ref.read(transactionProvider.notifier);

      // Process checkout (returns bool instead of Map)
      final success = await transactionNotifier.processCheckout(
        paymentMethod: _selectedPaymentMethod,
        amountPaid: _amountPaid.toStringAsFixed(0),
      );

      if (!mounted) return;

      if (success) {
        // Get transaction state to get completed transaction
        final transactionState = ref.read(transactionProvider);
        final completedTransaction = transactionState.completedTransaction;

        if (completedTransaction == null) {
          throw Exception('Data transaksi tidak ditemukan');
        }

        // Clear cart after successful transaction
        ref.read(cartProvider.notifier).clearCart();

        // Close payment dialog
        Navigator.of(context).pop(true);

        // Show receipt dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ReceiptWidget(
            transaction: completedTransaction,
          ),
        );
      } else {
        // Get error message from transaction state
        final transactionState = ref.read(transactionProvider);
        final errorMessage = transactionState.error ?? 'Transaksi gagal';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionProvider);
    final suggestedAmounts = [
      widget.totalAmount,
      (widget.totalAmount / 1000).ceil() * 1000,
      ((widget.totalAmount / 1000).ceil() * 1000) + 5000,
      ((widget.totalAmount / 1000).ceil() * 1000) + 10000,
      50000.0,
      100000.0,
    ].where((amount) => amount >= widget.totalAmount).toSet().toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 450,
          maxHeight: 700,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      color: AppTheme.citrusOrange,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pembayaran',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Total Amount
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.leafGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.leafGreen, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Total Pembayaran:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currencyFormat.format(widget.totalAmount),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.citrusOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Method Selection
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPaymentMethodChip('cash', 'Tunai', Icons.money),
                    _buildPaymentMethodChip(
                        'transfer', 'Transfer', Icons.account_balance),
                    _buildPaymentMethodChip('qris', 'QRIS', Icons.qr_code),
                    _buildPaymentMethodChip('card', 'Kartu', Icons.credit_card),
                  ],
                ),
                const SizedBox(height: 24),

                // Amount Input (only for cash)
                if (_selectedPaymentMethod == 'cash') ...[
                  const Text(
                    'Jumlah Diterima',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    enabled: !_isProcessing,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.leafGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.leafGreen),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.citrusOrange, width: 2),
                      ),
                    ),
                    onChanged: _onAmountChanged,
                  ),
                  const SizedBox(height: 16),

                  // Suggested Amounts
                  const Text(
                    'Nominal Cepat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: suggestedAmounts.map((amount) {
                      return OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _setSuggestedAmount(amount.toDouble()),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.leafGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _currencyFormat.format(amount),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Change
                  if (_change >= 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _change > 0
                            ? AppTheme.brightYellow.withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kembalian:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          Text(
                            _currencyFormat.format(_change),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _change > 0
                                  ? AppTheme.citrusOrange
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kurang: ${_currencyFormat.format(_change.abs())}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                const SizedBox(height: 24),

                // Processing indicator
                if (transactionState.isProcessing) ...[
                  LinearProgressIndicator(
                    value: transactionState.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.leafGreen),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Memproses transaksi... ${(transactionState.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.darkGray),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'BATAL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_isProcessing ||
                                (_selectedPaymentMethod == 'cash' &&
                                    _change < 0))
                            ? null
                            : _processCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brightYellow,
                          foregroundColor: AppTheme.darkGray,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.darkGray),
                                ),
                              )
                            : const Text(
                                'PROSES PEMBAYARAN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChip(String value, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : AppTheme.darkGray,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      onSelected: _isProcessing
          ? null
          : (selected) {
              if (selected) _onPaymentMethodChanged(value);
            },
      selectedColor: AppTheme.leafGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.darkGray,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.leafGreen : Colors.grey[300]!,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
