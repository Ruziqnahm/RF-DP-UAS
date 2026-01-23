// Entry point dan konfigurasi utama aplikasi Flutter
// File: mobile/lib/main.dart
// Tujuan: Menyiapkan dependency injection sederhana (Provider)
// dan menjalankan widget root aplikasi.

import 'package:flutter/material.dart';
import 'package:mobile/presentation/pages/admin_dashboard_page.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/pages/splash_page.dart';

// Fungsi utama program. Flutter akan memanggil ini saat aplikasi dijalankan.
void main() {
  runApp(const MyApp());
}

// Widget root aplikasi. Menggunakan [MultiProvider] untuk menyuntikkan
// instance provider yang dibutuhkan seluruh UI (state management ringan).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Daftar provider global yang akan tersedia di seluruh widget tree.
      providers: [
        // Menyediakan state dan logika terkait pesanan (order)
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        // Menyediakan state dan logika terkait produk
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        // Judul aplikasi (tidak selalu ditampilkan, tapi berguna)
        title: 'RF Digital Printing',
        // Sembunyikan banner debug saat bukan mode debug
        debugShowCheckedModeBanner: false,
        // Tema aplikasi diambil dari file tema terpusat
        theme: AppTheme.lightTheme,
        // Halaman pertama yang ditampilkan saat aplikasi diluncurkan
        home: const SplashPage(),
      ),
    );
  }
}
