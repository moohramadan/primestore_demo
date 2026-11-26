class CartItemModel {
  final int variantId;
  final int productId;
  final String name;
  final String color;
  final String size;
  final String imageUrl;
  final String unitPrice;
  final int quantity;
  final String lineTotal;
  final bool inStock;

  CartItemModel({
    required this.variantId,
    required this.productId,
    required this.name,
    required this.color,
    required this.size,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.inStock,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      variantId: json['variant_id'],
      productId: json['product_id'],
      name: json['name'],
      color: json['color'],
      size: json['size'],
      imageUrl: json['image_url'],
      unitPrice: json['unit_price'],
      quantity: json['quantity'],
      lineTotal: json['line_total'],
      inStock: json['in_stock'],
    );
  }
}


class CartModel {
  final List<CartItemModel> items;
  final String subtotal;

  CartModel({required this.items, required this.subtotal});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List).map((v) => CartItemModel.fromJson(v)).toList(),
      subtotal: json['subtotal'],
    );
  }
}