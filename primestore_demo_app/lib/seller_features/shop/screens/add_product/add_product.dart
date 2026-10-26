import 'dart:async';
import 'dart:typed_data';

import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/data/repositories/product_repository.dart';
import 'package:demo_project/seller_features/autentication/controllers/add_product_controller.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/widgets/product_info.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:demo_project/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const int _maxPhotos = 5;

  final ImagePicker _imagePicker = ImagePicker();
  final ProductRepository _productRepository = ProductRepository();
  final List<Uint8List> _photos = [];
  List<String> _uploadedImagePaths = [];
  final Set<String> _pendingCleanupPaths = {};
  bool _isPickingPhoto = false;
  bool _isSavingProduct = false;
  bool _isCleaningUploads = false;
  bool _allowPop = false;

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto || _isCleaningUploads || _isSavingProduct) return;
    if (_photos.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can add up to 5 photos.')),
      );
      return;
    }

    setState(() => _isPickingPhoto = true);
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (photo == null) return;

      final bytes = await photo.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photos.add(bytes);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not pick photo: $error')));
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<void> _removePhoto(int index) async {
    if (_isSavingProduct || _isCleaningUploads) return;
    final uploadedPath = index < _uploadedImagePaths.length
        ? _uploadedImagePaths[index]
        : null;
    setState(() {
      _photos.removeAt(index);
      if (uploadedPath != null) _uploadedImagePaths.removeAt(index);
    });
    if (uploadedPath == null) return;

    try {
      await _productRepository.deleteUnusedProductImage(uploadedPath);
    } catch (error) {
      _pendingCleanupPaths.add(uploadedPath);
      if (!mounted) return;
      TLoaders.errorSnackBar(
        title: 'Image cleanup failed',
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _discardAndClose() async {
    if (_isSavingProduct || _isCleaningUploads) return;
    setState(() => _isCleaningUploads = true);
    try {
      final paths = {..._uploadedImagePaths, ..._pendingCleanupPaths};
      for (final path in paths) {
        await _productRepository.deleteUnusedProductImage(path);
      }
      _pendingCleanupPaths.clear();
      _uploadedImagePaths.clear();
      if (!mounted) return;
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      TLoaders.errorSnackBar(
        title: 'Image cleanup failed',
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isCleaningUploads = false);
    }
  }

  Future<void> _saveProduct() async {
    if (_isSavingProduct || _isCleaningUploads) return;
    final controller = addProductController;
    if (controller.isLoadingProductOptions.value ||
        controller.productOptionsError.value != null ||
        controller.selectedCategoryId.value == null) {
      TLoaders.errorSnackBar(
        title: 'Cannot save product',
        message: 'Wait for categories and brands to load before saving.',
      );
      return;
    }
    if (_photos.isEmpty) {
      TLoaders.errorSnackBar(
        title: 'Cannot save product',
        message: 'Add at least one product photo.',
      );
      return;
    }
    final problem = controller.validate();
    if (problem != null) {
      TLoaders.errorSnackBar(title: 'Check your product', message: problem);
      return;
    }

    setState(() => _isSavingProduct = true);
    try {
      for (final path in _pendingCleanupPaths.toList()) {
        await _productRepository.deleteUnusedProductImage(path);
        _pendingCleanupPaths.remove(path);
      }
      final imagePaths = await _productRepository.uploadProductImages(
        _photos,
        existingPaths: _uploadedImagePaths,
        onPathsUpdated: (paths) => _uploadedImagePaths = List<String>.of(paths),
      );
      await controller.submitProduct(imagePaths: imagePaths);
      if (!mounted) return;
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TLoaders.successSnackBar(
          title: 'Product added',
          message: 'Your product was created successfully.',
        );
      });
    } catch (error) {
      if (!mounted) return;
      TLoaders.errorSnackBar(
        title: 'Could not add product',
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSavingProduct = false);
    }
  }

  @override
  void dispose() {
    Get.delete<AddProductController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return PopScope<void>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_discardAndClose());
      },
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyActions: true,
        titleSpacing: TSizes.md * 6,
        title: Text('Add product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TSectionHeading(title: 'Photos', showActionButton: false),
                  Text(
                    '${_photos.length} of $_maxPhotos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              Wrap(
                spacing: TSizes.spaceBtwInputFields,
                runSpacing: TSizes.spaceBtwInputFields,
                children: [
                  for (var index = 0; index < _photos.length; index++)
                    _buildPhotoTile(index, dark),
                  if (_photos.length < _maxPhotos) _buildAddPhotoTile(dark),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TSectionHeading(title: 'Product Info', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              ProductInfoContainer(
                onSave: _saveProduct,
                isSaving: _isSavingProduct,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildPhotoTile(int index, bool dark) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            child: Image.memory(_photos[index], fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: dark ? TColors.black.withValues(alpha: 0.7) : Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isSavingProduct || _isCleaningUploads
                    ? null
                    : () => _removePhoto(index),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoTile(bool dark) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Material(
        color: dark ? TColors.darkerGrey : TColors.grey,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        child: InkWell(
          onTap: _isPickingPhoto || _isSavingProduct || _isCleaningUploads
              ? null
              : _pickPhoto,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          child: Center(
            child: _isPickingPhoto
                ? const SizedBox(
                    height: TSizes.iconMd,
                    width: TSizes.iconMd,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _photos.isEmpty ? Iconsax.gallery : Iconsax.add,
                    size: TSizes.xl + 5,
                  ),
          ),
        ),
      ),
    );
  }
}
