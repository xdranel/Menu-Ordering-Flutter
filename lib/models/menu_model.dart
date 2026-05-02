class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? promoPrice;
  final bool isPromo;
  final bool available;
  final String? imageUrl;
  final int categoryId;
  final String categoryName;

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.promoPrice,
    required this.isPromo,
    required this.available,
    this.imageUrl,
    required this.categoryId,
    required this.categoryName,
  });

  double getCurrentPrice() =>
      isPromo && promoPrice != null ? promoPrice! : price;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return MenuItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      promoPrice: json['promoPrice'] != null
          ? (json['promoPrice'] as num).toDouble()
          : null,
      isPromo: json['isPromo'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      categoryId: category != null ? (category['id'] as num).toInt() : 0,
      categoryName: category != null ? category['name'] as String : '',
    );
  }
}
