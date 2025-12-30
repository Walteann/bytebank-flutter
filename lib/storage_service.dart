import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<Map<String, String>>> uploadTransactionFiles({
    required String userId,
    required List<File> files,
  }) async {
    final List<Map<String, String>> uploadedFiles = [];

    for (final file in files) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      final ref = _storage.ref('users/$userId/transactions/$fileName');

      await ref.putFile(file);

      final url = await ref.getDownloadURL();
      final path = ref.fullPath;

      uploadedFiles.add({'url': url, 'path': path});
    }

    return uploadedFiles;
  }

  Future<void> deleteFile(String path) async {
    final ref = _storage.ref(path);
    await ref.delete();
  }

  Future<String> getDownloadUrl(String path) async {
    final ref = _storage.ref(path);
    return await ref.getDownloadURL();
  }

  Reference getRefFromUrl(String url) {
    return _storage.refFromURL(url);
  }
}
