import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vreetory_app/features/authentication/presentation/pages/login_page.dart';
import 'package:vreetory_app/features/authentication/presentation/providers/auth_provider.dart';

import 'user_menu_page.dart';
import 'user_profile_page.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
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
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Text(
                'VreeTory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF4B7F52),
                ),
              ),
            ],
          ),
        ),
        // Cards
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: const [
              _HomeSectionCard(title: '7 Days to Expired'),
              SizedBox(height: 16),
              _HomeSectionCard(title: 'Today Expired'),
              SizedBox(height: 16),
              _HomeSectionCard(title: 'Stock Head Line'),
            ],
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
        bodyContent = const UserMenuPage();
        break;
      case 2:
        bodyContent = const UserProfilePage();
        break;
      default:
        bodyContent = _buildHomeContent();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD6FFB7),
      appBar: AppBar(
        title: const Text(
          'User Home',
          style: TextStyle(
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
        backgroundColor: const Color(0xFF4B7F52),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF4B7F52),
        selectedItemColor: const Color(0xFFFFD93D),
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

class _HomeSectionCard extends StatelessWidget {
  final String title;
  const _HomeSectionCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFD93D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF4B7F52),
              ),
            ),
            // Expanded for future content
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

