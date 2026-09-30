import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_document_picker/ios_document_picker_method_channel.dart';
import 'package:ios_document_picker/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IosDocumentPickerPath.release', () {
    test('releases a security-scoped URL only once', () async {
      final releasedUrls = <String>[];
      final path = IosDocumentPickerPath.fromMap(
        {
          'url': 'file:///document.txt',
          'path': '/document.txt',
          'name': 'document.txt',
        },
        onRelease: (url) async => releasedUrls.add(url),
      );

      await path.release();
      await path.release();

      expect(releasedUrls, ['file:///document.txt']);
    });

    test('does nothing without a release callback', () async {
      final path = IosDocumentPickerPath(
        'file:///document.txt',
        '/document.txt',
        'document.txt',
      );

      await expectLater(path.release(), completes);
    });

    test('does not throw when native release fails', () async {
      final path = IosDocumentPickerPath.fromMap(
        {
          'url': 'file:///document.txt',
          'path': '/document.txt',
          'name': 'document.txt',
        },
        onRelease: (_) => Future<void>.error(Exception('release failed')),
      );

      await expectLater(path.release(), completes);
    });
  });

  test('method channel releases the URL returned by pick', () async {
    final picker = MethodChannelIosDocumentPicker();
    MethodCall? releaseCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(picker.methodChannel, (call) async {
      if (call.method == 'pick') {
        return [
          {
            'url': 'file:///document.txt',
            'path': '/document.txt',
            'name': 'document.txt',
          }
        ];
      }
      releaseCall = call;
      return null;
    });

    final paths = await picker.pick(IosDocumentPickerType.file);
    await paths!.single.release();

    expect(releaseCall?.method, 'release');
    expect(releaseCall?.arguments, {'url': 'file:///document.txt'});
  });
}
