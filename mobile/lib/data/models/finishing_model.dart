class Finishing {
  final int id;
  final int productId;
  final String name;
  final double additionalPrice;
  final String? description;
  final bool isActive;

  Finishing({
    required this.id,
    required this.productId,
    required this.name,
    required this.additionalPrice,
    this.description,
    this.isActive = true,
  });

  factory Finishing.fromJson(Map<String, dynamic> json) {
    return Finishing(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      additionalPrice: (json['additional_price'] ?? 0.0).toDouble(),
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'additional_price': additionalPrice,
      'description': description,
      'is_active': isActive,
    };
  }
}
