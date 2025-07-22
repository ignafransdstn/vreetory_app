import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomePageScaffold(userType: 'Admin');
  }
}

class _HomePageScaffold extends StatelessWidget {
  final String userType;
  const _HomePageScaffold({required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6FFB7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome\n$userType Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF4B7F52)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Logo and App Name
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/asset1.png',
                    width: 80,
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
        ),
      ),
      bottomNavigationBar: const _HomeBottomNavBar(),
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

class _HomeBottomNavBar extends StatelessWidget {
  const _HomeBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      currentIndex: 0,
      onTap: (index) {},
      type: BottomNavigationBarType.fixed,
    );
  }
}