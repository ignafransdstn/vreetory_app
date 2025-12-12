# DOKUMENTASI APLIKASI — VreeTory App

Dokumentasi ringkas dan terperinci untuk pengembang: setup, menjalankan, build, struktur, asset, Firebase, dan pemecahan masalah.

---

## 1. Ikhtisar
- Nama aplikasi: VreeTory App
- Bahasa/framework: Flutter
- State management: Riverpod
- Backend: Firebase (Auth, Firestore)
- Lokasi proyek: root repository

## 2. Prasyarat
- Flutter SDK: sesuai `pubspec.yaml` (SDK: >=3.3.0 <4.0.0). Pastikan `flutter --version` memenuhi.
- Android SDK + platform-tools + build tools
- Xcode & CocoaPods (untuk iOS)
- Java JDK (untuk Android builds)
- Device / emulator untuk testing

## 3. Persiapan awal (clone & dependencies)
1. Clone repo

```bash
git clone <repo-url>
cd VreeTory
```

2. Instal dependencies

```bash
flutter pub get
```

3. Jika bekerja di iOS, jalankan:

```bash
cd ios
pod install
cd ..
```

## 4. Konfigurasi Firebase
- Repository sudah berisi file konfigurasi yang relevan: `lib/firebase_options.dart` dan beberapa `GoogleService-Info.plist` / `google-services.json` di folder platform.
- Jika mengganti project Firebase, regenerasikan `firebase_options.dart` menggunakan FlutterFire CLI atau tambahkan file platform yang sesuai.
- Pastikan file-service account / kunci sensitif tidak dipush pada repositori publik; lihat `serviceAccountKey.json` dan `vreetory-app-firebase-adminsdk-*.json` (jika ada) dan simpan aman.

## 5. Assets
- Lokasi utama: `assets/images/`
- Icon launcher yang dipakai: `assets/images/asset1.png`
- Icon di-generate menggunakan `flutter_launcher_icons`; konfigurasi ada di `pubspec.yaml`.

## 6. Menjalankan aplikasi
- Debug (default):

```bash
flutter run
```

- Hot reload/hot restart tersedia pada saat `flutter run`.

- Run pada device spesifik:

```bash
flutter run -d <device-id>
```

## 7. Build (release)
- Android (APK):

```bash
flutter build apk --release
```

- Android (App bundle):

```bash
flutter build appbundle --release
```

- iOS (archive/ipa): gunakan Xcode atau

```bash
flutter build ipa --export-options-plist=ExportOptions.plist
```

- Untuk build signed Android: siapkan keystore, lalu update `android/key.properties` dan `android/app/build.gradle` sesuai standar Flutter.

## 8. Testing
- Unit & widget tests:

```bash
flutter test
```

## 9. Perintah berguna
- Bersihkan cache/build

```bash
flutter clean
flutter pub get
```

- Analisa code

```bash
flutter analyze
```

- Format kode

```bash
dart format .
```

## 10. Struktur folder (penting)
- `lib/` — kode sumber utama
  - `features/` — feature-scoped modules (authentication, inventory, reporting, dll.)
  - `main.dart` — entrypoint
  - `firebase_options.dart` — konfigurasi firebase yang digenerate
- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` — platform builds
- `assets/images/` — gambar & icon
- `scripts/` — helper scripts (mis. seeding)

## 11. Release checklist singkat
1. Perbarui versi di `pubspec.yaml` (`version: X.Y.Z+build`)
2. Pastikan semua env / firebase config benar
3. Jalankan `flutter build` untuk platform target
4. Verifikasi icon & App name (sudah di-set ke "VreeTory App")
5. Uji pada device fisik jika memungkinkan

## 12. Troubleshooting umum
- Missing plugin / native build errors:
  - Jalankan `flutter pub get` lalu `flutter clean`, rebuild
  - Untuk iOS: `cd ios && pod install --repo-update`
- Firebase errors (auth / firestore): periksa `lib/firebase_options.dart` dan file google-services / plist
- Text overflow UI: beberapa widget sudah diperbaiki; cek log debug untuk stack trace
- Jika icon belum berubah pada device: uninstall aplikasi lama dari device lalu install ulang

## 13. Keamanan & file sensitif
- Jangan commit API keys atau private keys ke repositori publik.
- Ada beberapa file kredensial di repo (`serviceAccountKey.json`, `vreetory-app-firebase-adminsdk-*.json`). Pastikan ini disimpan aman dan .gitignore diatur sesuai kebijakan.

## 14. Memulihkan dokumentasi yang dihapus
- Jika ingin mengembalikan dokumen yang dihapus, Anda bisa:

```bash
git checkout -- README.md
```

atau mencari commit sebelumnya dan restore file lewat `git restore` atau `git show <commit>:path/to/file > file`.

## 15. Kontak / Kontribusi
- Jika Anda butuh bantuan lebih lanjut: beri tahu perubahan spesifik yang diinginkan (contoh: menambahkan panduan CI/CD, cara sign APK, atau flow Firebase tertentu).

---

Dokumentasi ini dibuat ringkas tapi mencakup alur pengembangan sehari-hari. Jika Anda ingin saya tambahkan bagian terperinci (contoh: langkah signing Android + contoh `key.properties`, template `ExportOptions.plist`, atau panduan CI), saya akan tambahkan sekarang.

