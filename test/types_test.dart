import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_document_picker/ios_document_picker_method_channel.dart';
import 'package:ios_document_picker/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IosDocumentPickerPath.release', () {
    test('releases a security-scoped URL only once', () async {
      final releasedTokens = <String>[];
      final path = IosDocumentPickerPath.fromMap({
        'url': 'file:///document.txt',
        'path': '/document.txt',
        'name': 'document.txt',
        'accessToken': 'token',
      }, onRelease: (accessToken) async => releasedTokens.add(accessToken));

      await path.release();
      await path.release();

      expect(releasedTokens, ['token']);
    });

    test('does nothing when security-scoped access was not started', () async {
      var releaseCount = 0;
      final path = IosDocumentPickerPath.fromMap({
        'url': 'file:///document.txt',
        'path': '/document.txt',
        'name': 'document.txt',
      }, onRelease: (_) async => releaseCount++);

      await expectLater(path.release(), completes);

      expect(releaseCount, 0);
    });

    test('does not throw when native release fails', () async {
      final path = IosDocumentPickerPath.fromMap({
        'url': 'file:///document.txt',
        'path': '/document.txt',
        'name': 'document.txt',
        'accessToken': 'token',
      }, onRelease: (_) => Future<void>.error(Exception('release failed')));

      await expectLater(path.release(), completes);
    });
  });

  test('method channel releases the access token returned by pick', () async {
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
                'accessToken': 'token',
              },
            ];
          }
          releaseCall = call;
          return null;
        });

    final paths = await picker.pick(IosDocumentPickerType.file);
    await paths!.single.release();

    expect(releaseCall?.method, 'release');
    expect(releaseCall?.arguments, {'accessToken': 'token'});
  });
}
