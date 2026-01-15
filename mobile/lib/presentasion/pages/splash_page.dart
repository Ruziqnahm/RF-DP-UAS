import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  
 @override
  void initState() {
    super.initState();
    
    // delay 2 detik lalu pindah ke home
    Timer(const Duration(seconds: 2), () {
      // Cek apakah widget masih aktif di layar
      if (mounted) { 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Image.asset(
              'assets/logo/rf_logo.png',
              width: 180,
              height: 180,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.print,
                  size: 100,
                  color: Colors.white,
                );
              },
            ),
            
            SizedBox(height: 24),
            
            Text(
              'RF Digital Printing',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 8),
            
            Text(
              'Solusi Cetak Digital Terpercaya',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            
            SizedBox(height: 48),
            
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
