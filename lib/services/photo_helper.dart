// lib/services/photo_helper.dart

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoHelper {
  PhotoHelper._();

  /// 앨범에서 여러 장 선택
  static Future<List<String>> pickFromGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isEmpty) return [];

    return _copyToAppDir(images);
  }

  /// 카메라로 한 장 촬영
  static Future<List<String>> takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return [];
    return _copyToAppDir([image]);
  }

  /// 선택/촬영한 이미지를 앱 전용 폴더로 복사하고, 최종 경로 리스트 리턴
  static Future<List<String>> _copyToAppDir(List<XFile> files) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/round_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final List<String> result = [];
    for (final f in files) {
      final file = File(f.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          f.name;
      final newPath = '${photosDir.path}/$fileName';
      await file.copy(newPath);
      result.add(newPath);
    }
    return result;
  }
}
