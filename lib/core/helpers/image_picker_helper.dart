import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum PickImageFailure implements Exception {
  cameraDenied('Camera access is blocked. Allow it from the app settings.'),
  photosDenied('Photos access is blocked. Allow it from the app settings.'),
  restricted('Camera access is restricted on this device.'),
  noCamera('No camera is available on this device.'),
  failed('Could not pick the picture. Please try again.');

  const PickImageFailure(this.message);

  final String message;

  bool get canOpenSettings =>
      this == cameraDenied || this == photosDenied;
}

class ImagePickerHelper {
  const ImagePickerHelper._();

  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
    } on PlatformException catch (error) {
      throw switch (error.code) {
        'camera_access_denied' => PickImageFailure.cameraDenied,
        'photo_access_denied' => PickImageFailure.photosDenied,
        'camera_access_restricted' => PickImageFailure.restricted,
        'no_available_camera' => PickImageFailure.noCamera,
        _ => PickImageFailure.failed,
      };
    } on PickImageFailure {
      rethrow;
    } catch (_, stackTrace) {
      Error.throwWithStackTrace(PickImageFailure.failed, stackTrace);
    }
  }

  static Future<XFile?> showPicker(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;
    return pickImage(source);
  }
}
