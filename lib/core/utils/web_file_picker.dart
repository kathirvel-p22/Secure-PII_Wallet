import 'dart:html' as html;
import 'dart:typed_data';

class WebFilePicker {
  static Future<WebFile?> pickFile() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf,.jpg,.jpeg,.png';
    uploadInput.click();

    await uploadInput.onChange.first;

    final files = uploadInput.files;
    if (files!.isEmpty) return null;

    final file = files[0];
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    return WebFile(
      name: file.name,
      bytes: reader.result as Uint8List,
      size: file.size,
    );
  }
}

class WebFile {
  final String name;
  final Uint8List bytes;
  final int size;

  WebFile({
    required this.name,
    required this.bytes,
    required this.size,
  });

  String get path => name; // For compatibility with File.path
}