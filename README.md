# VreeTory App - Sistem Manajemen Inventori & POS

[![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-purple)](https://riverpod.dev)

Aplikasi manajemen inventori dan Point of Sale (POS) yang dibangun dengan Flutter, menggunakan Firebase sebagai backend, dan Riverpod untuk state management.

---

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Teknologi](#-teknologi)
- [Prasyarat](#-prasyarat)
- [Instalasi](#-instalasi)
- [Konfigurasi Firebase](#-konfigurasi-firebase)
- [Menjalankan Aplikasi](#-menjalankan-aplikasi)
- [Build Release](#-build-release)
- [Struktur Project](#-struktur-project)
- [Fitur Upload Gambar](#-fitur-upload-gambar)
- [Troubleshooting](#-troubleshooting)
- [Kontribusi](#-kontribusi)

---

## 🚀 Fitur Utama

### Manajemen Inventori
- ✅ Tambah, edit, dan hapus item inventori
- ✅ **Upload gambar produk** (kamera/galeri)
- ✅ Tracking stok real-time
- ✅ Minimum stock alerts
- ✅ Kategori produk
- ✅ Manajemen supplier

### Point of Sale (POS)
- ✅ Antarmuka kasir yang intuitif
- ✅ **Tampilan gambar produk** di katalog
- ✅ Pencarian produk cepat
- ✅ Kalkulasi otomatis
- ✅ Riwayat transaksi
- ✅ Cetak struk (PDF)

### Pelaporan
- ✅ Laporan penjualan harian/bulanan/tahunan
- ✅ Top products analytics
- ✅ Grafik revenue trends
- ✅ Export data

### Autentikasi & Keamanan
- ✅ Firebase Authentication
- ✅ Role-based access (Admin/User)
- ✅ Secure data dengan Firestore rules
- ✅ Password reset

---

## 🛠 Teknologi

| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **Flutter** | 3.3.0+ | Framework UI |
| **Dart** | 3.0+ | Programming Language |
| **Firebase Core** | 2.32.0 | Backend Platform |
| **Firebase Auth** | 4.20.0 | User Authentication |
| **Cloud Firestore** | 4.17.5 | Database NoSQL |
| **Firebase Storage** | 11.7.7 | **Cloud Storage untuk Gambar** |
| **Riverpod** | 2.6.1 | State Management |
| **Image Picker** | 1.0.7 | **Ambil Gambar Kamera/Galeri** |
| **FL Chart** | 0.69.2 | Data Visualization |
| **Printing** | 5.13.1 | PDF Generation |
| **Share Plus** | 7.2.2 | Sharing Functionality |

---

## 📦 Prasyarat

Sebelum memulai, pastikan Anda telah menginstall:

- **Flutter SDK** (versi 3.3.0 atau lebih tinggi)
  ```bash
  flutter --version
  ```
- **Android Studio** / **VS Code** dengan Flutter plugin
- **Java JDK** 17+ (untuk Android build)
- **Android SDK** (API 21 - 36)
- **Xcode** (untuk iOS build - hanya di macOS)
- **Git**
- **Firebase CLI** (untuk deployment)
  ```bash
  npm install -g firebase-tools
  ```
- **Google Cloud SDK** (untuk Storage bucket management)

---

## 📥 Instalasi

### 1. Clone Repository
```bash
git clone https://github.com/ignafransdstn/vreetory_app.git
cd vreetory_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Install iOS Dependencies (jika develop di macOS)
```bash
cd ios
pod install
cd ..
```

### 4. Verify Installation
```bash
flutter doctor
```

---

## 🔥 Konfigurasi Firebase

### Setup Firebase Project

1. **Buat Firebase Project**
   - Buka [Firebase Console](https://console.firebase.google.com)
   - Klik "Add project" atau gunakan project yang sudah ada
   - Project yang digunakan: `vreetory-app`

2. **Enable Firebase Services**
   - **Authentication**: Enable Email/Password provider
   - **Cloud Firestore**: Create database di region `asia-southeast2`
   - **Firebase Storage**: Enable storage bucket (untuk gambar produk)

3. **Generate Firebase Configuration**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure --project=vreetory-app
   ```

4. **Download Configuration Files**
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### Firebase Storage Rules

File `storage.rules` sudah dikonfigurasi:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/vreetory-app.firebasestorage.app/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Deploy storage rules:
```bash
firebase deploy --only storage
```

### Firestore Security Rules

Pastikan rules di Firestore mengizinkan akses berdasarkan role:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /items/{itemId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🏃 Menjalankan Aplikasi

### Debug Mode

```bash
# Run di device yang tersambung
flutter run

# Run di device spesifik
flutter run -d <device-id>

# List available devices
flutter devices
```

### Hot Reload & Hot Restart

Saat aplikasi berjalan:
- **Hot Reload**: Tekan `r` (untuk UI changes)
- **Hot Restart**: Tekan `R` (untuk logic changes)
- **Quit**: Tekan `q`

---

## 📦 Build Release

### Android APK

```bash
# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (untuk Google Play)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release

# Atau gunakan Xcode untuk archive
open ios/Runner.xcworkspace
```

### Signing Configuration

Untuk production build, konfigurasi signing di:
- Android: `android/key.properties` dan `android/app/build.gradle`
- iOS: Xcode signing & capabilities

---

## 📁 Struktur Project

```
vreetory_app/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── firebase_options.dart              # Firebase config (auto-generated)
│   │
│   ├── core/
│   │   ├── services/
│   │   │   └── image_upload_service.dart  # 🆕 Service upload gambar
│   │   ├── models/
│   │   └── utils/
│   │
│   └── features/
│       ├── authentication/                # Auth features
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │
│       ├── inventory/                     # Inventory management
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       └── pages/
│       │           ├── add_item.dart      # 🆕 Upload gambar di Add Item
│       │           ├── edit_item_field.dart # 🆕 Upload gambar di Edit
│       │           └── inventory_list.dart
│       │
│       ├── pos/                           # Point of Sale
│       │   └── presentation/
│       │       └── pages/
│       │           └── cashier_page.dart  # 🆕 Display gambar produk
│       │
│       └── reporting/                     # Reports & Analytics
│
├── android/                               # Android native code
├── ios/                                   # iOS native code
├── assets/
│   └── images/                           # App assets
│
├── storage.rules                          # 🆕 Firebase Storage rules
├── firestore.rules                        # Firestore security rules
├── firebase.json                          # Firebase config
└── pubspec.yaml                          # Dependencies
```

---

## 📸 Fitur Upload Gambar

### Overview

Fitur upload gambar produk telah ditambahkan dengan integrasi **Firebase Storage** dan **Image Picker**.

### Fitur Utama

1. **Upload di Add Item Page** (Admin only)
   - Tombol Camera untuk mengambil foto langsung
   - Tombol Gallery untuk memilih dari galeri
   - Preview gambar sebelum disimpan
   - Kompresi otomatis (max 1920x1080, quality 85%)

2. **Upload di Edit Item Page** (Admin & User)
   - Tampilkan gambar existing
   - Update gambar dengan Camera/Gallery
   - Hapus gambar lama otomatis saat update

3. **Display di POS/Kasir Page**
   - Gambar produk ditampilkan di grid katalog (60% tinggi card)
   - Loading indicator saat load gambar
   - Fallback icon jika gambar tidak ada/error
   - Layout responsif dengan aspect ratio optimized

### Implementasi Teknis

#### ImageUploadService

Service centralized untuk handle semua operasi gambar:

```dart
class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Ambil dari kamera dengan kompresi
  Future<XFile?> pickImageFromCamera();
  
  // Ambil dari galeri dengan kompresi
  Future<XFile?> pickImageFromGallery();
  
  // Upload ke Firebase Storage
  Future<String> uploadImage(File imageFile, String itemCode);
  
  // Hapus gambar dari Storage
  Future<void> deleteImage(String imageUrl);
}
```

#### Storage Path Structure

```
items/
  └── {itemCode}_{timestamp}.jpg
```

Contoh: `items/ITM001_1734592800000.jpg`

#### Permissions

**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### Testing Upload Gambar

1. Login sebagai admin
2. Buka "Add Item"
3. Scroll ke "PRODUCT IMAGE"
4. Klik "Camera" atau "Gallery"
5. Pilih/ambil gambar
6. Gambar akan muncul di preview
7. Simpan item
8. Cek di POS - gambar tampil di card produk

---

## 🔧 Troubleshooting

### Firebase Storage Errors

**Error: `[firebase_storage/object-not-found]`**
- **Penyebab**: Storage bucket belum dibuat
- **Solusi**: 
  ```bash
  # Buat bucket via gcloud
  gcloud storage buckets create gs://vreetory-app.firebasestorage.app \
    --project=vreetory-app \
    --location=asia-southeast2
  
  # Deploy rules
  firebase deploy --only storage
  ```

**Error: `[firebase_storage/unauthorized]`**
- **Penyebab**: Storage rules tidak mengizinkan user
- **Solusi**: Pastikan bucket name di `storage.rules` benar:
  ```javascript
  match /b/vreetory-app.firebasestorage.app/o {
    allow read, write: if request.auth != null;
  }
  ```

### Build Errors

**Gradle Version Mismatch**
```bash
# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version 8.11.1
cd ..
```

**JDK Version Issues**
- Pastikan menggunakan JDK 17 atau 21
- Set `JAVA_HOME` environment variable

**SDK Version Errors**
- Update `compileSdk` dan `targetSdk` ke 36 di `android/app/build.gradle`

### Image Picker Issues

**Camera tidak muncul**
- Cek permissions di `AndroidManifest.xml`
- Test di physical device (emulator kadang tidak support kamera)

**Gambar tidak terupload**
- Cek koneksi internet
- Verify Firebase Authentication (user harus login)
- Cek Firebase Console → Storage → Files

---

## 🧹 Maintenance Commands

```bash
# Clean build cache
flutter clean

# Reinstall dependencies
flutter pub get

# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Update dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated
```

---

## 📊 Performance Tips

1. **Image Optimization**
   - Gambar otomatis dikompres ke 1920x1080 @ 85% quality
   - Gunakan `CachedNetworkImage` untuk cache gambar (coming soon)

2. **Firestore Queries**
   - Index fields yang sering di-query
   - Gunakan pagination untuk list besar

3. **State Management**
   - Gunakan `select` untuk optimize Riverpod rebuilds
   - Avoid nested providers

---

## 🔐 Security Best Practices

1. **Credentials**
   - Jangan commit `google-services.json` dan `GoogleService-Info.plist` ke public repo
   - Gunakan `.gitignore` untuk sensitive files

2. **Firebase Rules**
   - Review Firestore dan Storage rules secara berkala
   - Implement role-based access
   - Enable App Check untuk production

3. **API Keys**
   - Restrict Firebase API keys di Google Cloud Console
   - Set application restrictions

---

## 🤝 Kontribusi

Tertarik berkontribusi? Ikuti langkah berikut:

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📝 Changelog

### Version 1.1.0 (Latest)
- ✨ **NEW**: Upload gambar produk (Camera/Gallery)
- ✨ **NEW**: Display gambar di POS catalog
- ✨ **NEW**: Firebase Storage integration
- 🔧 Update build configuration (Gradle 8.11.1, AGP 8.9.1)
- 🔧 Update Android SDK to 36
- 📝 Improved documentation

### Version 1.0.0
- 🎉 Initial release
- ✅ Inventory management
- ✅ POS system
- ✅ Reporting & analytics
- ✅ Firebase authentication

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Igna Fransdstn**
- GitHub: [@ignafransdstn](https://github.com/ignafransdstn)
- Email: ignafransdstn@gmail.com

---

## 🙏 Acknowledgments

- Flutter Team untuk framework yang luar biasa
- Firebase untuk backend infrastructure
- Riverpod untuk elegant state management
- Community contributors

---

## 📞 Support

Butuh bantuan? Hubungi melalui:
- 📧 Email: ignafransdstn@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/ignafransdstn/vreetory_app/issues)

---

**Dibuat dengan ❤️ menggunakan Flutter**
