import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocumentsController extends GetxController {
  static const _maxFileSize = 10 * 1024 * 1024;

  final selectedImage = Rxn<File>();
  final _imagePicker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      final file = File(image.path);
      final extension = image.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        _showMessage('Choose a JPG or PNG image.');
        return;
      }

      if (await file.length() > _maxFileSize) {
        _showMessage('The image must be 10 MB or smaller.');
        return;
      }

      selectedImage.value = file;
    } catch (_) {
      _showMessage('Could not select the image. Please try again.');
    }
  }

  void _showMessage(String message) {
    Get.snackbar('Document upload', message);
  }
}
