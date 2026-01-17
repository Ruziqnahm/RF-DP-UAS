import 'package:flutter/material.dart';
import 'package:rf_digital_printing/core/theme/app_theme.dart';
import 'package:rf_digital_printing/data/models/product_model.dart';
import 'package:rf_digital_printing/presentation/pages/product_detail_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Kami'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layanan Digital Printing',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Berbagai macam layanan berkualitas tinggi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Service Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildServiceCard(
                    context,
                    title: 'Cetak Fancy Paper',
                    description: 'HVS, Art Paper, Flyer, Brosur, Poster, Undangan dengan berbagai pilihan kertas berkualitas.',
                    price: 'Mulai Rp 5.000',
                    icon: Icons.description,
                    gradient: [Colors.blue[400]!, Colors.blue[600]!],
                    onTap: () {
                      // Navigate to fancy paper product
                      final product = Product.getDummyProducts().firstWhere(
                        (p) => p.name.toLowerCase().contains('card') || p.name.toLowerCase().contains('paper'),
                        orElse: () => Product.getDummyProducts()[2],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildServiceCard(
                    context,
                    title: 'Packaging & Label',
                    description: 'Label Stiker, Packaging Custom, Mug Sublim dengan hasil yang rapi dan tahan lama.',
                    price: 'Mulai Rp 3.000',
                    icon: Icons.inventory_2,
                    gradient: [Colors.orange[400]!, Colors.orange[600]!],
                    onTap: () {
                      final product = Product.getDummyProducts().firstWhere(
                        (p) => p.name.toLowerCase().contains('sticker'),
                        orElse: () => Product.getDummyProducts()[1],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildServiceCard(
                    context,
                    title: 'Banner & Spanduk',
                    description: 'Flexi Indoor/Outdoor, Backlit, Albatros dengan berbagai pilihan finishing profesional.',
                    price: 'Mulai Rp 15.000/m²',
                    icon: Icons.flag,
                    gradient: [Colors.green[400]!, Colors.green[600]!],
                    onTap: () {
                      final product = Product.getDummyProducts().firstWhere(
                        (p) => p.name.toLowerCase().contains('banner'),
                        orElse: () => Product.getDummyProducts()[0],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildServiceCard(
                    context,
                    title: 'UV Printing',
                    description: 'Akrilik Flatbed, ID Card, Lanyard, Custom Casing HP dengan teknologi UV terdepan.',
                    price: 'Mulai Rp 10.000',
                    icon: Icons.print,
                    gradient: [Colors.purple[400]!, Colors.purple[600]!],
                    onTap: () {
                      final product = Product.getDummyProducts().firstWhere(
                        (p) => p.name.toLowerCase().contains('uv'),
                        orElse: () => Product.getDummyProducts()[3],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom CTA
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 48,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak menemukan yang Anda cari?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hubungi kami untuk konsultasi gratis dan dapatkan penawaran terbaik!',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String description,
    required String price,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Header with Gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
