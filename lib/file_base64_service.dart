import 'dart:convert';
import 'dart:io';

class FileBase64Service {
  Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<List<String>> filesToBase64(List<File> files) async {
    final List<String> base64Files = [];

    for (final file in files) {
      final base64 = await fileToBase64(file);
      base64Files.add(base64);
    }

    return base64Files;
  }
}
