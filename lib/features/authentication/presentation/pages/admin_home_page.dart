import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../../../inventory/domain/entities/item_entity.dart';
import '../../../inventory/presentation/provider/item_provider.dart';
import '../../../inventory/presentation/providers/low_stock_provider.dart';
import '../../../inventory/domain/entities/low_stock_alert_item.dart';
import 'expired_items_list_page.dart';
import 'stock_headline_detail_page.dart';
import 'low_stock_alert_detail_page.dart';

import 'admin_menu_page.dart';
import 'admin_profile_page.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // Logo and App Name
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            children: [
              Image.asset(
                'assets/images/asset1.png',
                width: 200,
                height: 80,
              ),
              const SizedBox(height: 4),
              const Text(
                'Inventory App',
                style: TextStyle(color: AppTheme.darkGray, fontSize: 12),
              ),
              const Text(
                'VreeTory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.limeGreen,
                ),
              ),
            ],
          ),
        ),
        // Cards with actual data
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final itemState = ref.watch(itemProvider);

              // Fetch items on first load
              ref.listen(itemProvider, (previous, next) {
                if (previous == null) {
                  ref.read(itemProvider.notifier).fetchAllItems();
                }
              });

              if (itemState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _SevenDaysExpiredSection(items: itemState.items),
                  const SizedBox(height: 16),
                  _TodayExpiredSection(items: itemState.items),
                  const SizedBox(height: 16),
                  const _LowStockNotificationSection(),
                  const SizedBox(height: 16),
                  _StockHeadLineSection(items: itemState.items),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = _buildHomeContent();
        break;
      case 1:
        bodyContent = const AdminMenuPage();
        break;
      case 2:
        bodyContent = const AdminProfilePage();
        break;
      default:
        bodyContent = _buildHomeContent();
    }

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Home' : _selectedIndex == 1 ? 'Menu' : 'Profile',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        backgroundColor: AppTheme.darkGreen,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.darkGreen,
        selectedItemColor: AppTheme.brightYellow,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'MENU',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _SevenDaysExpiredSection extends StatelessWidget {
  final List<ItemEntity> items;
  const _SevenDaysExpiredSection({required this.items});

  bool _isExpiringSoon(String expiredDate) {
    try {
      final expDate = DateFormat('dd/MM/yyyy').parse(expiredDate);
      final today = DateTime.now();
      final difference = expDate.difference(today).inDays;
      return difference > 0 && difference <= 7;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiringItems =
        items.where((item) => _isExpiringSoon(item.expiredDate)).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExpiredItemsListPage(
              title: '7 Days to Expired',
              type: 'seven_days',
            ),
          ),
        );
      },
      child: Card(
        color: AppTheme.brightYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '7 Days to Expired (${expiringItems.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (expiringItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No items expiring soon',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
              else
                ...expiringItems.take(3).map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item.expiredDate,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    )),
              if (expiringItems.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${expiringItems.length - 3} more',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayExpiredSection extends StatelessWidget {
  final List<ItemEntity> items;
  const _TodayExpiredSection({required this.items});

  bool _isExpired(String expiredDate) {
    try {
      final expDate = DateFormat('dd/MM/yyyy').parse(expiredDate);
      final today = DateTime.now();
      return expDate.isBefore(DateTime(today.year, today.month, today.day + 1));
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiredItems =
        items.where((item) => _isExpired(item.expiredDate)).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExpiredItemsListPage(
              title: 'Today Expired',
              type: 'today_expired',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.red.shade400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Today Expired (${expiredItems.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (expiredItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No expired items',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                )
              else
                ...expiredItems.take(3).map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item.expiredDate,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    )),
              if (expiredItems.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${expiredItems.length - 3} more',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockHeadLineSection extends StatelessWidget {
  final List<ItemEntity> items;
  const _StockHeadLineSection({required this.items});

  ItemEntity? _getLastUpdatedItem() {
    if (items.isEmpty) return null;
    ItemEntity latest = items.first;
    for (var item in items) {
      if (item.updatedAt.isAfter(latest.updatedAt)) {
        latest = item;
      }
    }
    return latest;
  }

  @override
  Widget build(BuildContext context) {
    final lastUpdated = _getLastUpdatedItem();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StockHeadlineDetailPage(),
          ),
        );
      },
      child: Card(
        color: AppTheme.limeGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Stock Head Line',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (lastUpdated == null)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No stock updates yet',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Updated Item:',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastUpdated.itemName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Updated At:',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm')
                                    .format(lastUpdated.updatedAt),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Updated By:',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lastUpdated.updatedBy,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LowStockNotificationSection extends ConsumerWidget {
  const _LowStockNotificationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockItems = ref.watch(lowStockItemsProvider);

    return lowStockItems.when(
      data: (items) {
        // Filter to show only critical and warning items
        final alertItems = items.where((item) {
          return item.status == LowStockStatus.critical ||
              item.status == LowStockStatus.warning;
        }).toList();

        final criticalItems = alertItems
            .where((item) => item.status == LowStockStatus.critical)
            .length;
        final warningItems = alertItems
            .where((item) => item.status == LowStockStatus.warning)
            .length;

        if (alertItems.isEmpty) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LowStockAlertDetailPage(),
                ),
              );
            },
            child: Card(
              color: AppTheme.citrusOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Low Stock Alert',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'All stock levels are good',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LowStockAlertDetailPage(),
              ),
            );
          },
          child: Card(
            color: AppTheme.citrusOrange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Low Stock Alert (${alertItems.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Critical: $criticalItems',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Warning: $warningItems',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Card(
        color: AppTheme.citrusOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      ),
      error: (err, stack) => Card(
        color: AppTheme.citrusOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Low Stock Alert',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Error loading',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
