import 'package:demo_project/data/repositories/cart_items_repository.dart';
import 'package:demo_project/features/shop/models/cart_model.dart';
import 'package:get/get.dart';
// import your CartItemsRepository and CartModel

class CartController extends GetxController {
  static const int maxQuantity = 10; // keep in sync with the backend

  final _repo = CartItemsRepository();

  final cart = Rxn<CartModel>();      // null until the first fetch finishes
  final isLoading = false.obs;        // true only for the full-screen load
  final busyVariantIds = <int>{}.obs; // variants with a request in flight

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  /// Total units in the cart (for the badge on the cart icon).
  int get itemCount =>
      cart.value?.items.fold<int>(0, (sum, i) => sum + i.quantity) ?? 0;

  bool get isEmpty => cart.value == null || cart.value!.items.isEmpty;

  /// True if any item has fewer units in stock than the cart holds.
  bool get hasUnavailableItems =>
      cart.value?.items.any((i) => !i.inStock) ?? false;

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      cart.value = await _repo.getCart();
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Runs one write call for a single variant, then refetches the cart.
  /// While it runs, that variant is marked busy so the UI can disable its buttons.
  /// Returns true if the write succeeded.
  Future<bool> _run(int variantId, Future<void> Function() action) async {
    if (busyVariantIds.contains(variantId)) return false; // ignore double taps
    busyVariantIds.add(variantId);
    try {
      await action();
      cart.value = await _repo.getCart(); // server is the source of truth
      return true;
    } catch (e) {
      _showError(e);
      return false;
    } finally {
      busyVariantIds.remove(variantId);
    }
  }

  Future<bool> addToCart(int variantId, {int quantity = 1}) => _run(
        variantId,
        () => _repo.addCartItem(
          productVariantId: variantId,
          quantity: quantity,
        ),
      );

  Future<bool> setQuantity(int variantId, int quantity) {
    if (quantity < 1 || quantity > maxQuantity) return Future.value(false);
    return _run(
      variantId,
      () => _repo.setCartItemQuantity(
        productVariantId: variantId,
        quantity: quantity,
      ),
    );
  }

  Future<bool> removeItem(int variantId) =>
      _run(variantId, () => _repo.removeCartItem(variantId));

  /// Call on logout so the next user doesn't see this cart.
  void clearLocal() => cart.value = null;

  void _showError(Object e) {
    Get.snackbar('Cart', e.toString().replaceFirst('Exception: ', ''));
  }
}