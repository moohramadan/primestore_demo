import 'package:demo_project/common/widgets/texts/t_subtitle.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/upload_documents/controllers/upload_documents_controller.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadImage extends StatelessWidget {
  const UploadImage({super.key, required this.controller});

  final UploadDocumentsController controller;

  Future<void> _showImageSourceOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceOptions(context),
          child: CustomPaint(
            painter: const _DashedBorderPainter(
              color: Color(0x590261F0),
              radius: 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: Obx(() {
                final selectedImage = controller.selectedImage.value;
                if (selectedImage != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(selectedImage, fit: BoxFit.contain),
                  );
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: TColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.badge_outlined,
                        size: 34,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: TSizes.md),
                    Text(
                      'Tap to upload',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: TSizes.sm),
                    const TSubtitle(title: 'JPG, PNG (max 10MB)'),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Center(
          child: TextButton(
            onPressed: () => controller.pickImage(ImageSource.gallery),
            child: const Text(
              'Or choose from your gallery',
              style: TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dashLength = 7.0;
    const gapLength = 5.0;

    for (final metric in borderPath.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
