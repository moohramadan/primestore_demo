class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String subtotal;
  final String deliveryFee;
  final String total;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final items = json['items'];
    if (id is! num ||
        json['order_number'] is! String ||
        json['status'] is! String ||
        json['payment_status'] is! String ||
        json['subtotal'] is! String ||
        json['delivery_fee'] is! String ||
        json['total'] is! String ||
        json['created_at'] is! String ||
        items is! List) {
      throw const FormatException('The server returned an invalid order.');
    }

    return OrderModel(
      id: id.toInt(),
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      subtotal: json['subtotal'] as String,
      deliveryFee: json['delivery_fee'] as String,
      total: json['total'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: items.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('The server returned an invalid order.');
        }
        return OrderItemModel.fromJson(item);
      }).toList(),
    );
  }
}

class OrderItemModel {
  final int variantId;
  final int productId;
  final String name;
  final String variantLabel;
  final String imageUrl;
  final String unitPrice;
  final int quantity;
  final String lineTotal;

  const OrderItemModel({
    required this.variantId,
    required this.productId,
    required this.name,
    required this.variantLabel,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    if (json['variant_id'] is! num ||
        json['product_id'] is! num ||
        json['name'] is! String ||
        json['variant_label'] is! String ||
        json['image_url'] is! String ||
        json['unit_price'] is! String ||
        json['quantity'] is! num ||
        json['line_total'] is! String) {
      throw const FormatException('The server returned an invalid order item.');
    }

    return OrderItemModel(
      variantId: (json['variant_id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      name: json['name'] as String,
      variantLabel: json['variant_label'] as String,
      imageUrl: json['image_url'] as String,
      unitPrice: json['unit_price'] as String,
      quantity: (json['quantity'] as num).toInt(),
      lineTotal: json['line_total'] as String,
    );
  }
}
