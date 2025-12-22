import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../pos/domain/entities/transaction_entity.dart';
import '../../domain/entities/sales_summary_entity.dart';

class SalesExcelExporter {
  static Future<void> exportReconciliationReport({
    required List<TransactionEntity> transactions,
    required SalesSummaryEntity summary,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Rekonsiliasi Sales'];

    // Remove default sheet
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final numberFormat = NumberFormat('#,##0', 'id_ID');

    // Filter completed transactions
    final completedTransactions =
        transactions.where((t) => t.status == 'completed').toList();

    // Header Section
    int currentRow = 0;

    // Title
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow),
    );
    var titleCell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    titleCell.value = TextCellValue('LAPORAN REKONSILIASI REVENUE VS SALES');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
    );
    currentRow += 2;

    // Period
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow),
    );
    var periodCell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    periodCell.value = TextCellValue(
        'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}');
    periodCell.cellStyle =
        CellStyle(fontSize: 12, horizontalAlign: HorizontalAlign.Center);
    currentRow += 2;

    // Summary Section
    _addHeaderCell(sheet, 0, currentRow, 'RINGKASAN', bold: true);
    currentRow++;

    _addDataRow(sheet, currentRow++, 'Total Transaksi',
        numberFormat.format(summary.totalTransactions));
    _addDataRow(sheet, currentRow++, 'Total Revenue (Sales)',
        currencyFormat.format(summary.totalSales));
    _addDataRow(sheet, currentRow++, 'Total Profit',
        currencyFormat.format(summary.totalProfit));
    _addDataRow(sheet, currentRow++, 'Total Discount',
        currencyFormat.format(summary.totalDiscount));
    _addDataRow(sheet, currentRow++, 'Rata-rata Transaksi',
        currencyFormat.format(summary.averageTransaction));
    _addDataRow(sheet, currentRow++, 'Total Item Terjual',
        numberFormat.format(summary.totalItemsSold));
    currentRow += 2;

    // Payment Method Breakdown
    _addHeaderCell(sheet, 0, currentRow, 'BREAKDOWN METODE PEMBAYARAN',
        bold: true);
    currentRow++;

    _addTableHeader(sheet, currentRow++,
        ['Metode', 'Jumlah Transaksi', 'Total Revenue', 'Persentase']);

    final totalRevenue =
        summary.paymentMethodBreakdown.values.fold(0.0, (a, b) => a + b);
    summary.paymentMethodBreakdown.forEach((method, amount) {
      final count = summary.paymentMethodCount[method] ?? 0;
      final percentage = (amount / totalRevenue * 100).toStringAsFixed(2);

      _addTableRow(sheet, currentRow++, [
        method.toUpperCase(),
        numberFormat.format(count),
        currencyFormat.format(amount),
        '$percentage%',
      ]);
    });
    currentRow += 2;

    // Transaction Details
    _addHeaderCell(sheet, 0, currentRow, 'DETAIL TRANSAKSI', bold: true);
    currentRow++;

    _addTableHeader(sheet, currentRow++, [
      'No',
      'Tanggal',
      'No. Transaksi',
      'Kasir',
      'Metode Pembayaran',
      'Subtotal',
      'Diskon',
      'Total',
      'Profit',
      'Item Terjual',
    ]);

    int transactionNo = 1;
    for (var transaction in completedTransactions) {
      final itemCount = transaction.items.fold(0.0, (sum, item) {
        return sum + (double.tryParse(item.quantity) ?? 0.0);
      });

      _addTableRow(sheet, currentRow++, [
        transactionNo.toString(),
        DateFormat('dd/MM/yyyy HH:mm').format(transaction.transactionDate),
        transaction.transactionNumber,
        transaction.cashier.name,
        transaction.paymentMethod.toUpperCase(),
        currencyFormat.format(double.tryParse(transaction.subtotal) ?? 0),
        currencyFormat.format(double.tryParse(transaction.discount) ?? 0),
        currencyFormat.format(double.tryParse(transaction.totalAmount) ?? 0),
        currencyFormat.format(double.tryParse(transaction.totalProfit) ?? 0),
        QuantityFormatter.format(itemCount.toString()),
      ]);
      transactionNo++;
    }
    currentRow += 2;

    // Reconciliation Verification
    _addHeaderCell(sheet, 0, currentRow, 'VERIFIKASI REKONSILIASI', bold: true);
    currentRow++;

    // Calculate totals from detail
    double detailTotalSales = 0;
    double detailTotalProfit = 0;
    double detailTotalDiscount = 0;

    for (var transaction in completedTransactions) {
      detailTotalSales += double.tryParse(transaction.totalAmount) ?? 0;
      detailTotalProfit += double.tryParse(transaction.totalProfit) ?? 0;
      detailTotalDiscount += double.tryParse(transaction.discount) ?? 0;
    }

    _addTableHeader(sheet, currentRow++,
        ['Item', 'Summary', 'Detail', 'Selisih', 'Status']);

    // Sales Verification
    final salesDiff = summary.totalSales - detailTotalSales;
    _addVerificationRow(sheet, currentRow++, 'Total Sales', summary.totalSales,
        detailTotalSales, salesDiff, currencyFormat);

    // Profit Verification
    final profitDiff = summary.totalProfit - detailTotalProfit;
    _addVerificationRow(sheet, currentRow++, 'Total Profit',
        summary.totalProfit, detailTotalProfit, profitDiff, currencyFormat);

    // Discount Verification
    final discountDiff = summary.totalDiscount - detailTotalDiscount;
    _addVerificationRow(
        sheet,
        currentRow++,
        'Total Discount',
        summary.totalDiscount,
        detailTotalDiscount,
        discountDiff,
        currencyFormat);

    currentRow += 2;

    // Footer
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow),
    );
    var footerCell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    footerCell.value = TextCellValue(
        'Dicetak pada: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    footerCell.cellStyle =
        CellStyle(fontSize: 10, horizontalAlign: HorizontalAlign.Center);

    // Set column widths
    for (int i = 0; i < 10; i++) {
      sheet.setColumnWidth(i, 18);
    }

    // Create Detail Items Sheet
    _createDetailItemsSheet(excel, completedTransactions, startDate, endDate);

    // Save and share file
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileNameFormat = DateFormat('dd-MM-yyyy');
      final fileName =
          'Rekonsiliasi_Sales_${fileNameFormat.format(startDate)}_${fileNameFormat.format(endDate)}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Laporan Rekonsiliasi Sales',
        text:
            'Laporan Rekonsiliasi Revenue vs Sales periode ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
      );
    }
  }

  static void _addHeaderCell(Sheet sheet, int col, int row, String text,
      {bool bold = false}) {
    var cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(
      bold: bold,
      fontSize: 12,
      backgroundColorHex: ExcelColor.fromHexString('#D9D9D9'),
    );
  }

  static void _addDataRow(Sheet sheet, int row, String label, String value) {
    var labelCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    labelCell.value = TextCellValue(label);
    labelCell.cellStyle = CellStyle(bold: true);

    var valueCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
    valueCell.value = TextCellValue(value);
  }

  static void _addTableHeader(Sheet sheet, int row, List<String> headers) {
    for (int i = 0; i < headers.length; i++) {
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );
    }
  }

  static void _addTableRow(Sheet sheet, int row, List<String> values) {
    for (int i = 0; i < values.length; i++) {
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = TextCellValue(values[i]);

      // Alternate row colors
      if (row % 2 == 0) {
        cell.cellStyle = CellStyle(
          backgroundColorHex: ExcelColor.fromHexString('#F2F2F2'),
        );
      }
    }
  }

  static void _addVerificationRow(
    Sheet sheet,
    int row,
    String label,
    double summaryValue,
    double detailValue,
    double diff,
    NumberFormat format,
  ) {
    final status = diff.abs() < 0.01 ? '✓ COCOK' : '✗ TIDAK COCOK';
    final bgColor = diff.abs() < 0.01 ? '#C6EFCE' : '#FFC7CE';

    _addTableRow(sheet, row, [
      label,
      format.format(summaryValue),
      format.format(detailValue),
      format.format(diff.abs()),
      status,
    ]);

    // Highlight status cell
    var statusCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row));
    statusCell.cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString(bgColor),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
  }

  static void _createDetailItemsSheet(
    Excel excel,
    List<TransactionEntity> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final sheet = excel['Detail Item Terjual'];
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    int currentRow = 0;

    // Title
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: currentRow),
    );
    var titleCell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    titleCell.value = TextCellValue('DETAIL ITEM TERJUAL PER TRANSAKSI');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
    );
    currentRow += 2;

    // Period
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: currentRow),
    );
    var periodCell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    periodCell.value = TextCellValue(
        'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}');
    periodCell.cellStyle =
        CellStyle(fontSize: 12, horizontalAlign: HorizontalAlign.Center);
    currentRow += 2;

    // Table Header
    _addTableHeader(sheet, currentRow++, [
      'No',
      'Tanggal',
      'No. Transaksi',
      'Kasir',
      'Nama Item',
      'Kategori',
      'Qty',
      'Measure',
      'Harga Satuan',
      'Subtotal',
      'Profit',
    ]);

    int itemNo = 1;
    for (var transaction in transactions) {
      for (var item in transaction.items) {
        _addTableRow(sheet, currentRow++, [
          itemNo.toString(),
          DateFormat('dd/MM/yyyy HH:mm').format(transaction.transactionDate),
          transaction.transactionNumber,
          transaction.cashier.name,
          item.itemName,
          item.category,
          QuantityFormatter.format(item.quantity),
          item.measure,
          currencyFormat.format(double.tryParse(item.unitPrice) ?? 0),
          currencyFormat.format(double.tryParse(item.subtotal) ?? 0),
          currencyFormat.format(double.tryParse(item.profit) ?? 0),
        ]);
        itemNo++;
      }
    }

    currentRow += 2;

    // Summary
    final totalItems = transactions.fold(
        0,
        (sum, t) =>
            sum +
            t.items.fold(0, (s, i) => s + (int.tryParse(i.quantity) ?? 0)));
    final totalRevenue = transactions.fold(
        0.0,
        (sum, t) =>
            sum +
            t.items
                .fold(0.0, (s, i) => s + (double.tryParse(i.subtotal) ?? 0)));
    final totalProfit = transactions.fold(
        0.0,
        (sum, t) =>
            sum +
            t.items.fold(0.0, (s, i) => s + (double.tryParse(i.profit) ?? 0)));

    _addHeaderCell(sheet, 0, currentRow, 'TOTAL', bold: true);
    currentRow++;
    _addDataRow(sheet, currentRow++, 'Total Item Terjual',
        NumberFormat('#,##0', 'id_ID').format(totalItems));
    _addDataRow(sheet, currentRow++, 'Total Revenue',
        currencyFormat.format(totalRevenue));
    _addDataRow(sheet, currentRow++, 'Total Profit',
        currencyFormat.format(totalProfit));

    currentRow += 2;

    // Footer
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: currentRow),
    );
    var footerCell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    footerCell.value = TextCellValue(
        'Dicetak pada: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    footerCell.cellStyle =
        CellStyle(fontSize: 10, horizontalAlign: HorizontalAlign.Center);

    // Set column widths
    for (int i = 0; i < 11; i++) {
      sheet.setColumnWidth(i, 18);
    }
  }
}
