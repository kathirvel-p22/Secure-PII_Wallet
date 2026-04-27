class WebFilePicker {
  static Future<WebFile?> pickFile() async {
    return null;
  }
}

class WebFile {
  final String name;
  final List<int> bytes;
  final int size;

  WebFile({
    required this.name,
    required this.bytes,
    required this.size,
  });

  String get path => name;
}