// lib/services/photo_helper.dart
//
// 사진 선택/촬영 후 앱 전용 폴더에 복사하고
// 최종 파일 경로(List<String>)를 돌려주는 헬퍼

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
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

  /// 선택/촬영한 XFile 들을 앱 전용 폴더로 복사하고, 최종 경로 리스트 반환
  static Future<List<String>> _copyToAppDir(List<XFile> files) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDocDir.path}/round_photos');

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final List<String> result = [];

    for (final xf in files) {
      final srcFile = File(xf.path);
      if (!await srcFile.exists()) continue;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(xf.path)}';
      final destPath = p.join(photosDir.path, fileName);

      await srcFile.copy(destPath);
      result.add(destPath);
    }

    return result;
  }
}
