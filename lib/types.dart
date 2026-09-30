enum IosDocumentPickerType { file, directory }

class IosDocumentPickerPath {
  final String url;
  final String path;
  final String name;
  final String? _accessToken;
  final Future<void> Function(String accessToken)? _release;
  bool _released = false;

  IosDocumentPickerPath(
    this.url,
    this.path,
    this.name, {
    String? accessToken,
    Future<void> Function(String accessToken)? onRelease,
  }) : _accessToken = accessToken,
       _release = onRelease;

  static IosDocumentPickerPath fromMap(
    Map<dynamic, dynamic> map, {
    Future<void> Function(String accessToken)? onRelease,
  }) {
    return IosDocumentPickerPath(
      map['url'],
      map['path'],
      map['name'],
      accessToken: map['accessToken'],
      onRelease: onRelease,
    );
  }

  Future<void> release() async {
    final accessToken = _accessToken;
    final release = _release;
    if (_released || accessToken == null || release == null) {
      return;
    }

    _released = true;
    try {
      await release(accessToken);
    } catch (_) {}
  }

  @override
  String toString() {
    return 'DocumentPickerPath{name: $name, url: $url, path: $path}';
  }
}
