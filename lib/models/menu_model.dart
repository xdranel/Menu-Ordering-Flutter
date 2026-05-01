class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? promoPrice;
  final bool isOnPromo;
  final bool isAvailable;
  final String? imageUrl;
  final int categoryId;
  final String categoryName;

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.promoPrice,
    required this.isOnPromo,
    required this.isAvailable,
    this.imageUrl,
    required this.categoryId,
    required this.categoryName,
  });

  // Always use this — never read .price directly in UI code.
  double getCurrentPrice() =>
      isOnPromo && promoPrice != null ? promoPrice! : price;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      promoPrice: json['promoPrice'] != null
          ? (json['promoPrice'] as num).toDouble()
          : null,
      isOnPromo: json['isOnPromo'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'promoPrice': promoPrice,
        'isOnPromo': isOnPromo,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'categoryName': categoryName,
      };
}
