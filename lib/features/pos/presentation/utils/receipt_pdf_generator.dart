import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:vreetory_app/features/pos/domain/entities/transaction_entity.dart';

class ReceiptPdfGenerator {
  static Future<pw.Document> generateReceipt(
      TransactionEntity transaction) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Store Name
              pw.Center(
                child: pw.Text(
                  'VREETORY',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Point of Sale System',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 16),

              // Divider
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // Transaction Info
              _buildInfoRow('No. Transaksi', transaction.transactionNumber),
              _buildInfoRow(
                'Tanggal',
                DateFormat('dd MMM yyyy').format(transaction.transactionDate),
              ),
              _buildInfoRow(
                'Waktu',
                DateFormat('HH:mm:ss').format(transaction.transactionDate),
              ),
              _buildInfoRow('Kasir', transaction.cashier.name),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // Items
              ...transaction.items.map((item) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.itemName,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${item.quantity} x ${_formatCurrency(int.parse(item.sellRate))}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          _formatCurrency(int.parse(item.subtotal)),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                  ],
                );
              }),

              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    _formatCurrency(int.parse(transaction.totalAmount)),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _formatCurrency(int.parse(transaction.totalAmount)),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // Payment Info
              _buildInfoRow(
                'Metode Bayar',
                _getPaymentMethodName(transaction.paymentMethod),
              ),
              _buildInfoRow(
                'Jumlah Bayar',
                _formatCurrency(int.parse(transaction.amountPaid)),
              ),
              if (int.parse(transaction.change) > 0)
                _buildInfoRow(
                  'Kembalian',
                  _formatCurrency(int.parse(transaction.change)),
                  valueBold: true,
                ),

              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Terima kasih atas kunjungan Anda!',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Barang yang sudah dibeli tidak dapat dikembalikan',
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildInfoRow(String label, String value,
      {bool valueBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: valueBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String _getPaymentMethodName(String method) {
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
}
