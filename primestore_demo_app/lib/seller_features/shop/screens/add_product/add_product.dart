import 'dart:typed_data';

import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/widgets/product_info.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
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
  final List<Uint8List> _photos = [];
  bool _isPickingPhoto = false;

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;
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
      setState(() => _photos.add(bytes));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not pick photo: $error')));
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
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
              ProductInfoContainer(),
            ],
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
                onTap: () => _removePhoto(index),
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
          onTap: _isPickingPhoto ? null : _pickPhoto,
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
