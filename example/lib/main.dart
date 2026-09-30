import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ios_document_picker/ios_document_picker.dart';
import 'package:ios_document_picker/types.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _iosDocumentPickerPlugin = IosDocumentPicker();
  var _output = '';
  var _mode = IosDocumentPickerType.file;
  var _multiple = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(_output),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: const Text('File'),
                  leading: Radio<IosDocumentPickerType>(
                    value: IosDocumentPickerType.file,
                    groupValue: _mode,
                    onChanged: (IosDocumentPickerType? value) {
                      setState(() {
                        _mode = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Directory'),
                  leading: Radio<IosDocumentPickerType>(
                    value: IosDocumentPickerType.directory,
                    groupValue: _mode,
                    onChanged: (IosDocumentPickerType? value) {
                      setState(() {
                        _mode = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CheckboxListTile(
                    value: _multiple,
                    onChanged: (value) {
                      setState(() {
                        _multiple = value!;
                      });
                    },
                    title: const Text('Multiple selection')),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton(onPressed: _start, child: const Text('Pick'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _start() async {
    var result =
        await _iosDocumentPickerPlugin.pick(_mode, multiple: _multiple);
    if (result == null) {
      setState(() {
        _output = 'Cancelled';
      });
      return;
    }

    late final String output;
    try {
      output = result.map((e) => e.toString()).join('\n\n');
    } finally {
      await Future.wait(result.map((e) => e.release()));
    }

    setState(() {
      _output = output;
    });
  }
}
