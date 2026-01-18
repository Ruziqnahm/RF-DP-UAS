import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import '../providers/order_provider.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Kami'),
        elevation: 0,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = productProvider.products;

          if (products.isEmpty) {
            return const Center(
              child: Text('Belum ada layanan tersedia'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              String getSatuan(String name) {
                if (name.toLowerCase().contains('banner')) return '/Meter';
                if (name.toLowerCase().contains('fancy') ||
                    name.toLowerCase().contains('paper')) return '/Lembar';
                if (name.toLowerCase().contains('kartu')) return '/pack';
                if (name.toLowerCase().contains('uv')) return '/pack';
                return '';
              }

              return ProductCard(
                name: product.name,
                category: product.category,
                price:
                    'Rp ${_formatPrice(product.basePrice)}${getSatuan(product.name)}',
                imageUrl: product.imageUrl,
                onTap: () {
                  Provider.of<OrderProvider>(context, listen: false)
                      .setProduct(product);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
