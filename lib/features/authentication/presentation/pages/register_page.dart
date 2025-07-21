import 'package:flutter/material.dart';
// Import tambahan untuk fitur register dan approval admin
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String selectedRole = 'User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6FFB7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B7F52),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('REGISTER', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dan judul
              Image.asset('assets/images/asset1.png', width: 120, height: 100),
              const SizedBox(height: 8),
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        fillColor: Color(0xFFFFFDE4),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        fillColor: Color(0xFFFFFDE4),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Role',
                        fillColor: Color(0xFFFFFDE4),
                        filled: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'User', child: Text('User')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD600),
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          // Logika register user baru dan approval admin
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();
                          final role = selectedRole;

                          // Validasi input sederhana
                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email dan password wajib diisi!')),
                            );
                            return;
                          }

                          try {
                            // Cek koneksi internet
                            // (Sederhana: coba akses Firestore, jika error berarti tidak ada koneksi)
                            final firestore = FirebaseFirestore.instance;
                            final userRemote = UserRemoteDataSource(firestore);
                            final isRegistered = await userRemote.isEmailRegistered(email);

                            if (isRegistered) {
                              // Email sudah terdaftar
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Pendaftaran Gagal'),
                                  content: const Text('Email sudah terdaftar.'),
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
                                final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
                                    ),
                                  );
                                  // Sukses, redirect ke user_home_page
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const UserHomePage()),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Pendaftaran Gagal'),
                                    content: Text(e.message ?? 'Terjadi kesalahan saat mendaftar.'),
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
                                final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                                final user = credential.user;
                                if (user != null) {
                                  // Simpan request approval ke koleksi usersRequest
                                  final firestore = FirebaseFirestore.instance;
                                  final userRequestRemote = UserRequestRemoteDataSource(firestore);
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
                                    ),
                                  );
                                  // Tampilkan popup menunggu approval
                                  if (!mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Menunggu Persetujuan'),
                                      content: const Text('Akun admin Anda menunggu persetujuan admin lain. Silakan login setelah disetujui.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context); // Kembali ke halaman login
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
                                    title: const Text('Pendaftaran Gagal'),
                                    content: Text(e.message ?? 'Terjadi kesalahan saat mendaftar.'),
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
                                title: const Text('Koneksi Gagal'),
                                content: const Text('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'),
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
                        child: const Text('Register'),
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
