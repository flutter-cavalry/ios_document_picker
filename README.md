# ios_document_picker

[![pub package](https://img.shields.io/pub/v/ios_document_picker.svg)](https://pub.dev/packages/ios_document_picker)

Flutter wrapper of iOS `UIDocumentPickerViewController`. [UIScene adoption](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate) is required.

## Usage

```dart
import 'package:ios_document_picker/ios_document_picker.dart';
import 'package:ios_document_picker/types.dart';

final documentPicker = IosDocumentPicker();

final paths = await documentPicker.pick(IosDocumentPickerType.file);
if (paths == null) {
  // Cancelled.
  return;
}

for (final path in paths) {
  try {
    print(path.name);
    print(path.url);
    print(path.path);
  } finally {
    await path.release();
  }
}
```

The picker starts security-scoped access for returned URLs when required. Call
`release()` on each `IosDocumentPickerPath` after finishing with it. Calling
`release()` more than once is safe, and release failures are not thrown.

### Options

- `allowedUtiTypes`: List of allowed UTI types.
- `multiple`: Allow multiple selection.
