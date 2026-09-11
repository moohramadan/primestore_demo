import 'package:demo_project/common/widgets/icons/wislist_icon.dart';
import 'package:demo_project/features/shop/controllers/wishlist_controller.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/features/shop/screens/product_details/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import your existing product-tap navigation target here

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final wishlist = Get.find<WishlistController>();

  @override
  void initState() {
    super.initState();
    wishlist.loadWishlistItems();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Obx(() {
        if (wishlist.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wishlist.wishlistItems.isEmpty) {
          return const Center(child: Text('Nothing in your wishlist yet.'));
        }

        return GestureDetector(
          
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: wishlist.wishlistItems.length,
            itemBuilder: (context, index) {
              final product = wishlist.wishlistItems[index];
              return GestureDetector(
                onTap: () => Get.to(() => ProductDetail(product: product)),
                child: Stack(
                  children: [
                    // Swap this for your existing product card widget so
                    // styling matches Home/Category/Search exactly:
                    // ProductCard(product: product),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                            child: product.mainImageUrl != null && product.mainImageUrl!.startsWith('http')
                  ? Image.network(
                            product.mainImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                  : Image.asset(
                            product.mainImageUrl ?? 'assets/images/product_placeholder.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          ),
                          
                          
                          
                            const SizedBox(height: 4),
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('\$${product.defaultVariant?.price.toStringAsFixed(2) ?? '-'}'),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: WishlistIconButton(product: product),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
