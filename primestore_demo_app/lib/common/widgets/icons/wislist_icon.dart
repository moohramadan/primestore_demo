import 'package:demo_project/features/shop/controllers/wishlist_controller.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class WishlistIconButton extends StatelessWidget {
  final ProductModel product;
  final double size;

  const WishlistIconButton({
    super.key,
    required this.product,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    final wishlist = Get.find<WishlistController>();

    return Obx(() {
      final wishlisted = wishlist.isWishlisted(product.id);
      return GestureDetector(
        onTap: () => wishlist.toggle(product),
        child: Icon(
          wishlisted ? Icons.favorite : Icons.favorite_border,
          color: wishlisted ? Colors.red : Colors.grey,
          size: size,
        ),
      );
    });
  }
}
