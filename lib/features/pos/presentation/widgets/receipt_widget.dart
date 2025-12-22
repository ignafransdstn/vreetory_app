import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vreetory_app/core/theme/app_theme.dart';
import 'package:vreetory_app/features/pos/domain/entities/transaction_entity.dart';
import 'package:vreetory_app/features/pos/presentation/utils/receipt_pdf_generator.dart';

class ReceiptWidget extends StatelessWidget {
  final TransactionEntity transaction;

  const ReceiptWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.leafGreen,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'STRUK PEMBAYARAN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Transaksi Berhasil!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Receipt Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name
                      const Center(
                        child: Text(
                          'VREETORY',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Point of Sale System',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Transaction Info
                      _buildDashedLine(),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          'No. Transaksi', transaction.transactionNumber),
                      _buildInfoRow(
                          'Tanggal',
                          DateFormat('dd MMM yyyy')
                              .format(transaction.transactionDate)),
                      _buildInfoRow(
                          'Waktu',
                          DateFormat('HH:mm:ss')
                              .format(transaction.transactionDate)),
                      _buildInfoRow('Kasir', transaction.cashier.name),
                      const SizedBox(height: 12),
                      _buildDashedLine(),
                      const SizedBox(height: 12),

                      // Items List
                      ...transaction.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.quantity} x ${_formatCurrency(int.parse(item.sellRate))}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(int.parse(item.subtotal)),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),

                      const SizedBox(height: 12),
                      _buildDashedLine(),
                      const SizedBox(height: 12),

                      // Totals
                      _buildTotalRow(
                          'Subtotal', int.parse(transaction.totalAmount),
                          isBold: false),
                      const SizedBox(height: 8),
                      _buildTotalRow(
                          'TOTAL', int.parse(transaction.totalAmount),
                          isBold: true, isLarge: true),

                      const SizedBox(height: 16),
                      _buildDashedLine(),
                      const SizedBox(height: 12),

                      // Payment Info
                      _buildInfoRow('Metode Bayar',
                          _getPaymentMethodName(transaction.paymentMethod)),
                      _buildInfoRow('Jumlah Bayar',
                          _formatCurrency(int.parse(transaction.amountPaid))),
                      if (int.parse(transaction.change) > 0)
                        _buildInfoRow(
                          'Kembalian',
                          _formatCurrency(int.parse(transaction.change)),
                          valueColor: AppTheme.leafGreen,
                          valueBold: true,
                        ),

                      const SizedBox(height: 20),
                      _buildDashedLine(),
                      const SizedBox(height: 16),

                      // Footer Message
                      const Center(
                        child: Text(
                          'Terima kasih atas kunjungan Anda!',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Barang yang sudah dibeli tidak dapat dikembalikan',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 20),
                            label: const Text(
                              'TUTUP',
                              style: TextStyle(fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.darkGray,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareReceipt(context),
                            icon: const Icon(Icons.share, size: 20),
                            label: const Text(
                              'BAGIKAN',
                              style: TextStyle(fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.leafGreen,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _printReceipt(context),
                        icon: const Icon(Icons.print, size: 20),
                        label: const Text(
                          'PRINT / SIMPAN PDF',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.leafGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        40,
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index % 2 == 0 ? Colors.grey[400] : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppTheme.darkGray,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, int amount,
      {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isLarge ? AppTheme.leafGreen : AppTheme.darkGray,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'transfer':
        return 'Transfer Bank';
      case 'qris':
        return 'QRIS';
      case 'card':
        return 'Kartu Debit/Kredit';
      default:
        return method;
    }
  }

  Future<void> _printReceipt(BuildContext context) async {
    try {
      final pdf = await ReceiptPdfGenerator.generateReceipt(transaction);

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Receipt_${transaction.transactionNumber}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final pdf = await ReceiptPdfGenerator.generateReceipt(transaction);
      final bytes = await pdf.save();

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Receipt_${transaction.transactionNumber}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
