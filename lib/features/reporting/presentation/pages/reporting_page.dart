import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import 'stock_valuation_report_page.dart';
import 'expiry_alert_report_page.dart';
import 'inventory_movement_report_page.dart';
import 'loss_report_page.dart';
import 'sales_report_page.dart';
import '../../../inventory/presentation/pages/low_stock_alert_report_page.dart';

class ReportingPage extends ConsumerWidget {
  const ReportingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role;
    final isAdmin = userRole == 'admin';

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        title: const Text('REPORTING'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sales Report - Only visible for Admin
              if (isAdmin)
                Column(
                  children: [
                    ReportCard(
                      title: 'Sales Report',
                      subtitle: 'Daily & monthly sales analysis',
                      icon: Icons.point_of_sale,
                      color: const Color(0xFF4CAF50),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SalesReportPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              // Stock Valuation Report - Only visible for Admin
              if (isAdmin)
                Column(
                  children: [
                    ReportCard(
                      title: 'Stock Valuation Report',
                      subtitle: 'Total inventory value & breakdown',
                      icon: Icons.trending_up,
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StockValuationReportPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              // Expiry Alert Report
              ReportCard(
                title: 'Expiry Alert Report',
                subtitle: 'Items expiring soon',
                icon: Icons.warning_amber_rounded,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ExpiryAlertReportPage()),
                ),
              ),
              const SizedBox(height: 16),
              // Inventory Movement Report
              ReportCard(
                title: 'Inventory Movement Report',
                subtitle: 'Stock in/out/adjustment history',
                icon: Icons.move_to_inbox,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InventoryMovementReportPage()),
                ),
              ),
              const SizedBox(height: 16),
              // Low Stock Alert Report
              ReportCard(
                title: 'Low Stock Alert Report',
                subtitle: 'Items below minimum stock threshold',
                icon: Icons.notifications_active,
                color: Colors.red,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LowStockAlertReportPage()),
                ),
              ),
              const SizedBox(height: 16),
              // Loss & Damage Report - Only visible for Admin
              if (isAdmin)
                ReportCard(
                  title: 'Loss & Damage Report',
                  subtitle: 'Financial impact of inventory losses',
                  icon: Icons.trending_down,
                  color: const Color(0xFFD32F2F),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LossReportPage()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
