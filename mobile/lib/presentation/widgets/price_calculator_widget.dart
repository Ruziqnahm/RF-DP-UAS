import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class PriceCalculatorWidget extends StatelessWidget {
  const PriceCalculatorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final isComplete = provider.specification.isComplete();
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calculate,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Kalkulasi Harga',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                if (!isComplete) ...[
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lengkapi semua spesifikasi\nuntuk melihat estimasi harga',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Breakdown harga
                  _buildPriceRow(
                    'Biaya Material',
                    provider.materialCost,
                    icon: Icons.inventory_2,
                  ),
                  const SizedBox(height: 12),
                  
                  if (provider.finishingCost > 0) ...[
                    _buildPriceRow(
                      'Biaya Finishing',
                      provider.finishingCost,
                      icon: Icons.auto_awesome,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  _buildPriceRow(
                    'Jumlah',
                    provider.specification.quantity,
                    icon: Icons.shopping_cart,
                    isQuantity: true,
                  ),
                  const SizedBox(height: 12),
                  
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),
                  
                  _buildPriceRow(
                    'Subtotal',
                    provider.subtotal,
                    icon: Icons.calculate_outlined,
                    isBold: true,
                  ),
                  
                  if (provider.specification.isUrgent) ...[
                    const SizedBox(height: 12),
                    _buildPriceRow(
                      'Biaya Urgent (+30%)',
                      provider.urgentFee,
                      icon: Icons.flash_on,
                      iconColor: Colors.orange,
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 16),
                  
                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL BAYAR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Rp ${_formatPrice(provider.totalPrice)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Estimasi waktu pengerjaan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estimasi Pengerjaan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${provider.estimatedDays} Hari Kerja',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            if (provider.estimatedDeliveryDate != null)
                              Text(
                                'Selesai: ${_formatDate(provider.estimatedDeliveryDate!)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade700,
                                ),
                              ),
                          ],
                        ),
                        if (provider.specification.isUrgent) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flash_on,
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Pengerjaan dipercepat',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Breakdown detail
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text(
                      'Lihat Detail Perhitungan',
                      style: TextStyle(fontSize: 13),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildDetailRow('Luas Area', '${provider.specification.getArea().toStringAsFixed(2)} m²'),
                      _buildDetailRow('Ukuran', provider.specification.size == 'Custom' 
                          ? '${provider.specification.customWidth}x${provider.specification.customHeight} cm'
                          : provider.specification.size ?? '-'),
                      _buildDetailRow('Material', _getMaterialName(provider)),
                      _buildDetailRow('Finishing', provider.specification.finishing ?? '-'),
                      _buildDetailRow('Harga Material/m²', 'Rp ${_formatPrice(_getMaterialPrice(provider))}'),
                      if (provider.finishingCost > 0)
                        _buildDetailRow('Harga Finishing/m²', 'Rp ${_formatPrice(_getFinishingPricePerSqm(provider))}'),
                      _buildDetailRow('Harga/Unit', 'Rp ${_formatPrice((provider.materialCost + provider.finishingCost))}'),
                      _buildDetailRow('Quantity', '${provider.specification.quantity} pcs'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(
    String label,
    int value, {
    IconData? icon,
    Color? iconColor,
    bool isBold = false,
    bool isQuantity = false,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: iconColor ?? Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Text(
          isQuantity ? '$value pcs' : 'Rp ${_formatPrice(value)}',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMaterialName(OrderProvider provider) {
    final materials = [
      {'id': 1, 'name': 'Art Paper'},
      {'id': 2, 'name': 'Vinyl'},
      {'id': 3, 'name': 'Flexi'},
      {'id': 4, 'name': 'Albatros'},
    ];
    
    final material = materials.firstWhere(
      (m) => m['id'] == provider.specification.materialId,
      orElse: () => materials[0],
    );
    
    return material['name'] as String;
  }

  int _getMaterialPrice(OrderProvider provider) {
    final materials = [
      {'id': 1, 'price': 15000},
      {'id': 2, 'price': 25000},
      {'id': 3, 'price': 35000},
      {'id': 4, 'price': 20000},
    ];
    
    final material = materials.firstWhere(
      (m) => m['id'] == provider.specification.materialId,
      orElse: () => materials[0],
    );
    
    return material['price'] as int;
  }

  int _getFinishingPricePerSqm(OrderProvider provider) {
    if (provider.specification.finishing == 'Glossy' || 
        provider.specification.finishing == 'Doff') {
      return 3000;
    } else if (provider.specification.finishing == 'Laminating') {
      return 5000;
    }
    return 0;
  }
}
