import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> uploadTransactionFiles({
    required String userId,
    required List<File> files,
  }) async {
    final List<String> downloadUrls = [];

    for (final file in files) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      final ref = _storage.ref('users/$userId/transactions/$fileName');

      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      downloadUrls.add(url);
    }

    return downloadUrls;
  }
}
