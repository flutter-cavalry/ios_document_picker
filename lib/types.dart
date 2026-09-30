enum IosDocumentPickerType { file, directory }

class IosDocumentPickerPath {
  final String url;
  final String path;
  final String name;
  final Future<void> Function(String url)? _release;
  bool _released = false;

  IosDocumentPickerPath(
    this.url,
    this.path,
    this.name, {
    Future<void> Function(String url)? onRelease,
  }) : _release = onRelease;

  static IosDocumentPickerPath fromMap(
    Map<dynamic, dynamic> map, {
    Future<void> Function(String url)? onRelease,
  }) {
    return IosDocumentPickerPath(
      map['url'],
      map['path'],
      map['name'],
      onRelease: onRelease,
    );
  }

  Future<void> release() async {
    final release = _release;
    if (_released || release == null) {
      return;
    }

    _released = true;
    try {
      await release(url);
    } catch (_) {}
  }

  @override
  String toString() {
    return 'DocumentPickerPath{name: $name, url: $url, path: $path}';
  }
}
