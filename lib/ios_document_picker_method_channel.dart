import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ios_document_picker/types.dart';

import 'ios_document_picker_platform_interface.dart';

/// An implementation of [IosDocumentPickerPlatform] that uses method channels.
class MethodChannelIosDocumentPicker extends IosDocumentPickerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ios_document_picker');

  @override
  Future<List<IosDocumentPickerPath>?> pick(
    IosDocumentPickerType type, {
    bool? multiple,
    List<String>? allowedUtiTypes,
  }) async {
    var maps = await methodChannel.invokeListMethod<Map<dynamic, dynamic>>(
        'pick', {
      'type': type.index,
      'multiple': multiple,
      'allowedUtiTypes': allowedUtiTypes
    });
    if (maps == null) {
      return null;
    }
    return maps
        .map((e) => IosDocumentPickerPath.fromMap(
              e,
              onRelease: (url) => methodChannel.invokeMethod<void>(
                'release',
                {'url': url},
              ),
            ))
        .toList();
  }
}
