import 'dart:typed_data';
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AudioPreview extends StatefulWidget {
  final String? filePath; // unused on web
  final Uint8List? bytes;
  const AudioPreview({super.key, this.filePath, this.bytes});

  @override
  State<AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<AudioPreview> {
  String? _viewType;
  String? _objectUrl;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && widget.bytes != null) {
      final id = 'audio-view-${DateTime.now().microsecondsSinceEpoch}';
      _viewType = id;
      // register factory once per id
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(id, (int _) {
        final blob = html.Blob([widget.bytes!], 'audio/wav');
        _objectUrl = html.Url.createObjectUrl(blob);
        final el = html.AudioElement()
          ..src = _objectUrl!
          ..controls = true;
        return el;
      });
    }
  }

  @override
  void dispose() {
    if (_objectUrl != null) {
      html.Url.revokeObjectUrl(_objectUrl!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _viewType == null) return const SizedBox.shrink();
    return HtmlElementView(viewType: _viewType!);
  }
}
