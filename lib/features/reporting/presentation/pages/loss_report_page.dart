import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../providers/loss_provider.dart';
import '../../domain/entities/loss_record_entity.dart';
import 'package:intl/intl.dart';

class LossReportPage extends ConsumerStatefulWidget {
  const LossReportPage({super.key});

  @override
  ConsumerState<LossReportPage> createState() => _LossReportPageState();
}

class _LossReportPageState extends ConsumerState<LossReportPage> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    selectedEndDate = DateTime.now();
    selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: selectedStartDate ??
            DateTime.now().subtract(const Duration(days: 30)),
        end: selectedEndDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
        _currentPage = 0; // Reset to first page when date range changes
      });
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(value);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  Widget _buildErrorWidget(String errorMessage) {
    final isPermissionError = errorMessage.contains('PERMISSION_DENIED');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPermissionError ? 'Access Denied' : 'Error',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPermissionError
                ? 'You do not have permission to access the Loss & Damage report. Only admins can view this report.'
                : 'Failed to load data: $errorMessage',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
          if (isPermissionError) ...[
            const SizedBox(height: 12),
            Text(
              'Solusi:',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '1. Make sure you are logged in as an admin\n2. Check Firestore Security Rules in Firebase Console\n3. Logout and log back in',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lossRecordsAsync =
        selectedStartDate != null && selectedEndDate != null
            ? ref.watch(lossRecordsByDateRangeProvider(
                (selectedStartDate!, selectedEndDate!)))
            : ref.watch(lossRecordsProvider);

    final totalLossAsync =
        ref.watch(totalLossValueProvider((selectedStartDate, selectedEndDate)));
    final lossByReasonAsync = ref
        .watch(totalLossByReasonProvider((selectedStartDate, selectedEndDate)));

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        title: const Text('LOSS & DAMAGE REPORT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Range Filter Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Period:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatDate(selectedStartDate!)} - ${_formatDate(selectedEndDate!)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('Range'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Total Loss Card
              totalLossAsync.when(
                data: (totalLoss) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: _buildTotalLossCard(totalLoss),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildErrorWidget(err.toString()),
              ),
              const SizedBox(height: 16),

              // Loss by Reason Summary
              lossByReasonAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildErrorWidget(err.toString()),
                data: (lossByReason) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Loss by Reason',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildLossReasonCard(
                          'Expired Items',
                          lossByReason['Expired']?['quantity'] ?? 0,
                          lossByReason['Expired']?['totalLoss'] ?? 0.0,
                          const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 8),
                        _buildLossReasonCard(
                          'Damaged/Defective Items',
                          lossByReason['Demaged/Defective']?['quantity'] ?? 0,
                          lossByReason['Demaged/Defective']?['totalLoss'] ??
                              0.0,
                          const Color(0xFFFFA500),
                        ),
                        const SizedBox(height: 8),
                        _buildLossReasonCard(
                          'Lost Items',
                          lossByReason['Lost']?['quantity'] ?? 0,
                          lossByReason['Lost']?['totalLoss'] ?? 0.0,
                          const Color(0xFF6C757D),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Loss Records List
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loss Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      lossRecordsAsync.when(
                        data: (records) => records.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'No loss data available for this period',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  // Calculate pagination
                                  _buildPaginatedLossRecords(records),
                                  // Pagination Controls
                                  if ((records.length / _itemsPerPage).ceil() >
                                      1)
                                    _buildPaginationControls(records),
                                ],
                              ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            _buildErrorWidget(err.toString()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalLossCard(double totalLoss) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Loss',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(totalLoss),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLossReasonCard(
    String title,
    double quantity,
    double totalLoss,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _formatCurrency(totalLoss),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Quantity
          Text(
            'Qty: ${QuantityFormatter.format(quantity.toString())}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLossRecordTile(LossRecordEntity record) {
    Color reasonColor;
    switch (record.reasonType) {
      case 'Expired':
        reasonColor = const Color(0xFFFF6B6B);
        break;
      case 'Demaged/Defective':
        reasonColor = const Color(0xFFFFA500);
        break;
      case 'Lost':
        reasonColor = const Color(0xFF6C757D);
        break;
      default:
        reasonColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.itemName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${record.itemCode}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: reasonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  record.reasonType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: reasonColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: ${record.quantityLost}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatCurrency(double.tryParse(record.totalLoss) ?? 0),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Note: ${record.notes}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Created: ${_formatDate(record.createdAt)} by ${record.createdBy}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginatedLossRecords(List<LossRecordEntity> records) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, records.length);
    final paginatedRecords = records.sublist(startIndex, endIndex);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paginatedRecords.length,
      itemBuilder: (context, index) {
        final record = paginatedRecords[index];
        return _buildLossRecordTile(record);
      },
    );
  }

  Widget _buildPaginationControls(List<LossRecordEntity> records) {
    final totalPages = (records.length / _itemsPerPage).ceil();

    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.chevron_left),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.darkGreen,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Page ${_currentPage + 1} of $totalPages',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.chevron_right),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.darkGreen,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
