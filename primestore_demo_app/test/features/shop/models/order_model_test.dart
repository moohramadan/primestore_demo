import 'package:demo_project/features/shop/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderModel.fromJson', () {
    test('parses the checkout response', () {
      final order = OrderModel.fromJson({
        'id': 42,
        'order_number': 'PS-20261117-ABC234',
        'status': 'placed',
        'payment_status': 'unpaid',
        'subtotal': '30.00',
        'delivery_fee': '0.00',
        'total': '30.00',
        'created_at': '2026-11-17T10:00:00Z',
        'address': {
          'full_name': 'Ada Lovelace',
          'phone': '123',
          'address_line_1': '1 Example Street',
          'address_line_2': '',
          'city': 'Exampleville',
          'state': 'Example State',
          'postal_code': '12345',
          'country': 'Examplia',
        },
        'items': [
          {
            'variant_id': 3,
            'product_id': 7,
            'name': 'Shirt',
            'variant_label': 'Red / M',
            'image_url': 'https://example.test/shirt.jpg',
            'unit_price': '15.00',
            'quantity': 2,
            'line_total': '30.00',
          },
        ],
      });

      expect(order.id, 42);
      expect(order.orderNumber, 'PS-20261117-ABC234');
      expect(order.status, 'placed');
      expect(order.paymentStatus, 'unpaid');
      expect(order.total, '30.00');
      expect(order.createdAt, DateTime.utc(2026, 11, 17, 10));
      expect(order.items, hasLength(1));
      expect(order.items.single.variantLabel, 'Red / M');
      expect(order.items.single.quantity, 2);
      expect(order.items.single.lineTotal, '30.00');
    });

    test('rejects a malformed order response', () {
      expect(
        () => OrderModel.fromJson({'id': 'not-an-id'}),
        throwsFormatException,
      );
    });
  });
}
