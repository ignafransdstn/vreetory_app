import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'admin_home_page.dart';
import 'user_home_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        if (next.user!.role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomePage()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
        }
      } else if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFD6FFB7),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dan judul
              const SizedBox(height: 40),
              Image.asset('assets/logo.png', height: 80), // Ganti sesuai asset Anda
              const SizedBox(height: 16),
              const Text('Inventory App', style: TextStyle(color: Colors.grey)),
              const Text('VreeTory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B7F52),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 350,
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email', fillColor: Color(0xFFFFFDE4), filled: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', fillColor: Color(0xFFFFFDE4), filled: true),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD93D)),
                            onPressed: authState.status == AuthStatus.loading
                                ? null
                                : () {
                                    ref.read(authProvider.notifier).signIn(
                                          context,
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                  },
                            child: authState.status == AuthStatus.loading
                                ? const CircularProgressIndicator()
                                : const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD6FFB7)),
                            onPressed: () {
                              // TODO: Navigasi ke halaman register
                            },
                            child: const Text('Register'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // TODO: Forgot password
                      },
                      child: const Text('Forgot password?'),
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
}