import 'package:demo_project/data/repositories/product_repository.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/constants/currency.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Up to 8 whole digits and 2 decimals, the same rule the server uses.
final RegExp _moneyPattern = RegExp(r'^\d{1,8}(\.\d{1,2})?$');

/// "1299" -> 129900, "1299.5" -> 129950. Returns null when [raw] is not a
/// valid amount. Working in whole cents avoids floating point surprises.
int? _moneyToCents(String raw) {
  final text = raw.trim();
  if (!_moneyPattern.hasMatch(text)) return null;
  final parts = text.split('.');
  final whole = int.parse(parts[0]);
  final fraction = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
  return whole * 100 + fraction;
}

class EditSellerProductScreen extends StatefulWidget {
  const EditSellerProductScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<EditSellerProductScreen> createState() =>
      _EditSellerProductScreenState();
}

class _EditSellerProductScreenState extends State<EditSellerProductScreen> {
  // Categories and brands rarely change, so remember them between visits and
  // the screen opens instantly the second time.
  static List<ProductOption>? _cachedCategories;
  static List<ProductOption>? _cachedBrands;

  final _formKey = GlobalKey<FormState>();
  final _repository = ProductRepository();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final List<_EditableVariant> _variants;
  late final String _initialSignature;

  List<ProductOption> _categories = _cachedCategories ?? [];
  List<ProductOption> _brands = _cachedBrands ?? [];
  int? _categoryId;
  int? _brandId;
  bool _isLoadingOptions = _cachedCategories == null || _cachedBrands == null;
  String? _optionsError;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product.name);
    _descriptionController = TextEditingController(text: product.description);
    _variants = product.variants.map(_EditableVariant.new).toList();
    _categoryId = product.categoryId;
    _brandId = product.brandId;

    // Remember what the form looked like at the start, so we can tell later
    // whether the seller actually changed anything.
    _initialSignature = _signature();
    _nameController.addListener(_onEdited);
    _descriptionController.addListener(_onEdited);
    for (final variant in _variants) {
      variant.addListener(_onEdited);
    }

    if (_isLoadingOptions) _loadOptions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final variant in _variants) {
      variant.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Change tracking
  // ---------------------------------------------------------------------------

  String _signature() {
    return [
      _nameController.text.trim(),
      _descriptionController.text.trim(),
      _categoryId,
      _brandId,
      for (final variant in _variants) variant.signature,
    ].join('\u0001');
  }

  void _onEdited() {
    final changed = _signature() != _initialSignature;
    if (changed != _hasChanges && mounted) {
      setState(() => _hasChanges = changed);
    }
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits to this product have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  void _closeScreen([ProductModel? result]) {
    setState(() => _allowPop = true);
    Navigator.of(context).pop(result);
  }

  // ---------------------------------------------------------------------------
  // Categories and brands
  // ---------------------------------------------------------------------------

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchBrands(),
      ]);
      _cachedCategories = results[0];
      _cachedBrands = results[1];
      if (!mounted) return;
      setState(() {
        _categories = results[0];
        _brands = results[1];
        _isLoadingOptions = false;
        _optionsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingOptions = false;
        _optionsError = error.toString().replaceFirst('Exception: ', '');
      });
      TLoaders.errorSnackBar(
        title: 'Could not load product options',
        message: _optionsError!,
      );
    }
  }

  void _retryOptions() {
    setState(() {
      _isLoadingOptions = true;
      _optionsError = null;
    });
    _loadOptions();
  }

  /// Makes sure the product's current value is always selectable, even when
  /// the lists failed to load or the current category is hidden (like "All").
  List<ProductOption> _withCurrent(
    List<ProductOption> options,
    int? id,
    String name,
  ) {
    if (id == null || options.any((option) => option.id == id)) return options;
    return [
      ...options,
      ProductOption(id: id, name: name.isEmpty ? 'Current' : name),
    ];
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String? _validateMoney(String? value, {required String label}) {
    final cents = _moneyToCents(value ?? '');
    if (cents == null || cents <= 0) return 'Enter a valid $label price.';
    return null;
  }

  String? _validateSalePrice(_EditableVariant variant) {
    final amount = variant.salePriceController.text.trim();
    if (amount.isEmpty) return null;
    final validation = _validateMoney(amount, label: 'sale');
    if (validation != null) return validation;
    final sale = _moneyToCents(amount);
    final original = _moneyToCents(variant.priceController.text);
    if (sale != null && original != null && sale > original) {
      return 'Sale price cannot exceed the original price.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Saving
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_hasChanges) {
      _closeScreen();
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showMessage('Fix the highlighted fields first.', isError: true);
      return;
    }
    if (_categoryId == null) {
      _showMessage('Choose a category.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedProduct = await _repository.updateSellerProduct(
        widget.product.id,
        {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category_id': _categoryId,
          'brand_id': _brandId ?? 0,
          'variants': [
            for (final variant in _variants)
              {
                'id': variant.original.id,
                'color': variant.colorController.text.trim(),
                'size': variant.sizeController.text.trim(),
                'price': variant.priceController.text.trim(),
                'sale_price': variant.salePriceController.text.trim(),
                'stock': int.parse(variant.stockController.text.trim()),
              },
          ],
        },
      );
      if (!mounted) return;
      _closeScreen(updatedProduct);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (isError) {
      TLoaders.errorSnackBar(title: 'Check product details', message: message);
    } else {
      TLoaders.successSnackBar(title: 'Product updated', message: message);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final categoryOptions = _withCurrent(
      _categories,
      widget.product.categoryId,
      widget.product.categoryName,
    );
    final brandOptions = _withCurrent(
      _brands,
      widget.product.brandId,
      widget.product.brandName,
    );

    return PopScope<Object?>(
      // Leaving is free when nothing changed. Otherwise ask first, and never
      // allow leaving in the middle of a save.
      canPop: _allowPop || !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _isSaving) return;
        final discard = await _confirmDiscard();
        if (discard && mounted) _closeScreen();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit product')),
        body: _isLoadingOptions
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // A Column (not a lazy ListView) so every variant field exists
                // and is checked when the form is validated, even off-screen.
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_optionsError != null) ...[
                        _OptionsErrorBanner(
                          message: _optionsError!,
                          onRetry: _retryOptions,
                        ),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                      ],
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [LengthLimitingTextInputFormatter(150)],
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) => value?.trim().isNotEmpty == true
                            ? null
                            : 'Enter a product name.',
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      DropdownButtonFormField<int>(
                        initialValue: _categoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: [
                          for (final option in categoryOptions)
                            DropdownMenuItem<int>(
                              value: option.id,
                              child: Text(option.name),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() => _categoryId = value);
                          _onEdited();
                        },
                        validator: (value) =>
                            value == null ? 'Choose a category.' : null,
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),
                      DropdownButtonFormField<int>(
                        initialValue: _brandId ?? 0,
                        decoration: const InputDecoration(labelText: 'Brand'),
                        items: [
                          const DropdownMenuItem<int>(
                            value: 0,
                            child: Text('No brand'),
                          ),
                          for (final option in brandOptions)
                            DropdownMenuItem<int>(
                              value: option.id,
                              child: Text(option.name),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() => _brandId = value == 0 ? null : value);
                          _onEdited();
                        },
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                      Text(
                        'Variants',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      for (final variant in _variants)
                        _VariantEditor(
                          variant: variant,
                          validateMoney: _validateMoney,
                          validateSalePrice: _validateSalePrice,
                        ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(TSizes.defaultSpace),
          child: FilledButton(
            onPressed: _isSaving || _isLoadingOptions || !_hasChanges
                ? null
                : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save changes'),
          ),
        ),
      ),
    );
  }
}

class _OptionsErrorBanner extends StatelessWidget {
  const _OptionsErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Could not load categories and brands ($message). '
                'You can still save, or try again.',
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EditableVariant {
  _EditableVariant(this.original)
    : colorController = TextEditingController(text: original.color),
      sizeController = TextEditingController(text: original.size),
      priceController = TextEditingController(
        text: original.price.toStringAsFixed(2),
      ),
      salePriceController = TextEditingController(
        text: original.salePrice?.toStringAsFixed(2) ?? '',
      ),
      stockController = TextEditingController(text: original.stock.toString()) {
    // The sale price rule depends on the original price, so check the sale
    // field again whenever the original price changes.
    priceController.addListener(_revalidateSale);
  }

  final ProductVariantModel original;
  final TextEditingController colorController;
  final TextEditingController sizeController;
  final TextEditingController priceController;
  final TextEditingController salePriceController;
  final TextEditingController stockController;
  final GlobalKey<FormFieldState<String>> saleFieldKey =
      GlobalKey<FormFieldState<String>>();

  List<TextEditingController> get _controllers => [
    colorController,
    sizeController,
    priceController,
    salePriceController,
    stockController,
  ];

  /// All field values joined together, used to detect unsaved changes.
  String get signature =>
      _controllers.map((controller) => controller.text.trim()).join('|');

  void addListener(VoidCallback listener) {
    for (final controller in _controllers) {
      controller.addListener(listener);
    }
  }

  void _revalidateSale() {
    if (salePriceController.text.trim().isNotEmpty) {
      saleFieldKey.currentState?.validate();
    }
  }

  /// Whole percent off for the typed prices, or null when there is no valid sale.
  int? get percentOff {
    final originalCents = _moneyToCents(priceController.text);
    final saleCents = _moneyToCents(salePriceController.text);
    if (originalCents == null ||
        saleCents == null ||
        originalCents <= 0 ||
        saleCents <= 0 ||
        saleCents > originalCents) {
      return null;
    }
    return ((originalCents - saleCents) * 100 + originalCents ~/ 2) ~/
        originalCents;
  }

  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
  }
}

class _VariantEditor extends StatelessWidget {
  const _VariantEditor({
    required this.variant,
    required this.validateMoney,
    required this.validateSalePrice,
  });

  final _EditableVariant variant;
  final String? Function(String?, {required String label}) validateMoney;
  final String? Function(_EditableVariant) validateSalePrice;

  static const _moneyKeyboard = TextInputType.numberWithOptions(decimal: true);

  @override
  Widget build(BuildContext context) {
    final moneyFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              variant.original.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: variant.colorController,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    decoration: const InputDecoration(labelText: 'Color'),
                  ),
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: TextFormField(
                    controller: variant.sizeController,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                    decoration: const InputDecoration(labelText: 'Size'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: variant.priceController,
                    keyboardType: _moneyKeyboard,
                    textInputAction: TextInputAction.next,
                    inputFormatters: moneyFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Original price',
                      prefixText: TCurrency.symbol,
                    ),
                    validator: (value) =>
                        validateMoney(value, label: 'original'),
                  ),
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: TextFormField(
                    key: variant.saleFieldKey,
                    controller: variant.salePriceController,
                    keyboardType: _moneyKeyboard,
                    textInputAction: TextInputAction.next,
                    inputFormatters: moneyFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Sale price',
                      prefixText: TCurrency.symbol,
                      helperText: 'Empty = no sale',
                    ),
                    validator: (_) => validateSalePrice(variant),
                  ),
                ),
              ],
            ),
            // Live preview of the discount, and a quick way to end the sale.
            ListenableBuilder(
              listenable: Listenable.merge([
                variant.priceController,
                variant.salePriceController,
              ]),
              builder: (context, _) {
                final percent = variant.percentOff;
                final hasSale = variant.salePriceController.text
                    .trim()
                    .isNotEmpty;
                if (!hasSale) return const SizedBox.shrink();
                return Row(
                  children: [
                    if (percent != null && percent > 0)
                      Text(
                        '$percent% off',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: variant.salePriceController.clear,
                      child: const Text('Remove sale'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              controller: variant.stockController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Units in stock'),
              validator: (value) {
                final stock = int.tryParse(value?.trim() ?? '');
                if (stock == null || stock < 0 || stock > 1000000) {
                  return 'Enter stock from 0 to 1,000,000.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
