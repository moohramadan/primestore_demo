import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:get/get.dart';

import '../../../data/repositories/wishlist_repository.dart';

class WishlistController extends GetxController {
  final _repo = WishlistRepository();

  final RxSet<int> wishlistedIds = <int>{}.obs;
  final RxList<ProductModel> wishlistItems = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWishlistedIds();
  }

  bool isWishlisted(int productId) => wishlistedIds.contains(productId);

  Future<void> loadWishlistedIds() async {
    try {
      final ids = await _repo.fetchWishlistedIds();
      wishlistedIds.assignAll(ids);
    } catch (_) {
      // silent — the heart icons just default to unfilled until this succeeds
    }
  }

  Future<void> loadWishlistItems() async {
    isLoading.value = true;
    try {
      final items = await _repo.fetchWishlist();
      wishlistItems.assignAll(items);
      wishlistedIds.assignAll(items.map((p) => p.id));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Optimistically flips the heart immediately, then syncs with the
  /// backend. Rolls back on failure so the UI never lies about what's
  /// actually saved.
  Future<void> toggle(ProductModel product) async {
    final alreadyWishlisted = isWishlisted(product.id);

    if (alreadyWishlisted) {
      wishlistedIds.remove(product.id);
      wishlistItems.removeWhere((p) => p.id == product.id);
    } else {
      wishlistedIds.add(product.id);
      wishlistItems.add(product);
    }

    try {
      if (alreadyWishlisted) {
        await _repo.removeFromWishlist(product.id);
      } else {
        await _repo.addToWishlist(product.id);
      }
    } catch (e) {
      // roll back the optimistic update
      if (alreadyWishlisted) {
        wishlistedIds.add(product.id);
        wishlistItems.add(product);
      } else {
        wishlistedIds.remove(product.id);
        wishlistItems.removeWhere((p) => p.id == product.id);
      }
      Get.snackbar('Error', e.toString());
    }
  }
}
