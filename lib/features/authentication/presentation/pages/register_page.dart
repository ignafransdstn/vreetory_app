// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/datasources/user_request_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_request_model.dart';
import 'user_home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'REGISTER',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/asset1.png', width: 120, height: 100),
              const SizedBox(height: 8),
              const Text(
                'Inventory App',
                style: TextStyle(color: AppTheme.darkGray),
              ),
              const Text(
                'VreeTory',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppTheme.limeGreen),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.darkGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.limeGreen.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                width: 350,
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Email',
                        fillColor: AppTheme.cleanWhite,
                        filled: true,
                        prefixIcon:
                            const Icon(Icons.email, color: AppTheme.limeGreen),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Password',
                        fillColor: AppTheme.cleanWhite,
                        filled: true,
                        prefixIcon:
                            const Icon(Icons.lock, color: AppTheme.limeGreen),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: AppTheme.cleanWhite,
                        filled: true,
                      ),
                      hint: const Text('Role'),
                      items: const [
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'User', child: Text('User')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedElevatedButton(
                        label: 'Register',
                        backgroundColor: AppTheme.brightYellow,
                        foregroundColor: AppTheme.darkGray,
                        onPressed: () async {
                          // Logika register user baru dan approval admin
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();
                          final role = selectedRole ?? '';

                          // Validasi input sederhana
                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Email and password cannot be empty')),
                            );
                            return;
                          }

                          try {
                            // Cek koneksi internet
                            // (Sederhana: coba akses Firestore, jika error berarti tidak ada koneksi)
                            final firestore = FirebaseFirestore.instance;
                            final userRemote = UserRemoteDataSource(firestore);
                            final isRegistered =
                                await userRemote.isEmailRegistered(email);

                            if (isRegistered) {
                              // Email sudah terdaftar
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Failed to Register'),
                                  content: const Text(
                                      'Email is already registered. Please use a different email.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (role == 'User') {
                              // Proses register user biasa
                              try {
                                final credential = await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                                final user = credential.user;
                                if (user != null) {
                                  // Simpan data user ke Firestore
                                  await userRemote.createUser(
                                    UserModel(
                                      uid: user.uid,
                                      email: email,
                                      role: 'user',
                                      adminRequest: false,
                                      isApproved: true,
                                      createdAt: DateTime.now(),
                                      name: null,
                                      phone: null,
                                    ),
                                  );
                                  // Sukses, redirect ke user_home_page
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const UserHomePage()),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Registration Failed'),
                                    content: Text(e.message ??
                                        'An error occurred during registration.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else if (role == 'Admin') {
                              // Proses register admin: simpan request approval
                              try {
                                final credential = await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                                final user = credential.user;
                                if (user != null) {
                                  // Simpan request approval ke koleksi usersRequest
                                  final firestore = FirebaseFirestore.instance;
                                  final userRequestRemote =
                                      UserRequestRemoteDataSource(firestore);
                                  await userRequestRemote.createUserRequest(
                                    UserRequestModel(
                                      uid: user.uid,
                                      rid: user.uid,
                                      email: email,
                                      requestedAt: DateTime.now(),
                                      status: false,
                                    ),
                                  );
                                  // Simpan data user ke Firestore dengan isApproved: false
                                  await userRemote.createUser(
                                    UserModel(
                                      uid: user.uid,
                                      email: email,
                                      role: 'admin',
                                      adminRequest: true,
                                      isApproved: false,
                                      createdAt: DateTime.now(),
                                      name: null,
                                      phone: null,
                                    ),
                                  );
                                  // Tampilkan popup menunggu approval
                                  if (!mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Wait for Approval'),
                                      content: const Text(
                                          'Your admin request has been submitted. Please wait for approval.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(
                                                context); // Kembali ke halaman login
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Registration Failed'),
                                    content: Text(e.message ??
                                        'An error occurred during registration.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // Error koneksi atau error lain
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Connection Error'),
                                content: const Text(
                                    'Please check your internet connection and try again.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
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
}
