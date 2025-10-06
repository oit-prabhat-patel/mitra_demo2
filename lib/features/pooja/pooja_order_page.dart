import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prashna_pooja_app/core/uploader.dart';
import 'package:prashna_pooja_app/util/video_preview.dart';
import 'package:prashna_pooja_app/services/video_recorder.dart';

class PoojaOrderPage extends StatefulWidget {
  final String orderId;
  const PoojaOrderPage({super.key, required this.orderId});

  @override
  State<PoojaOrderPage> createState() => _PoojaOrderPageState();
}

class _PoojaOrderPageState extends State<PoojaOrderPage> {

  void _showVideoPreview() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final preview = kIsWeb
            ? VideoPreview(bytes: recordedBytesWeb ?? pickedBytes)
            : VideoPreview(filePath: recordedPath ?? pickedPath, bytes: pickedBytes);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Preview video', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(height: 260, child: preview),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  final MobileVideoRecorder _mobile = MobileVideoRecorder();
  Uint8List? pickedBytes;
  String? pickedPath;
  String? recordedPath;
  Uint8List? recordedBytesWeb;
  String status = 'Idle';

  @override
  void dispose() {
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _startVideo() async {
    try {
      setState(() => status = 'Opening camera…');
      await _mobile.init();
      await _mobile.start();
      setState(() => status = 'Recording…');
    } catch (e) {
      setState(() => status = 'Error: $e');
    }
  }

  Future<void> _stopVideo() async {
    try {
      final res = await _mobile.stop();
      recordedPath = res.path;
      if (kIsWeb && res.bytes != null) {
        recordedBytesWeb = Uint8List.fromList(res.bytes!);
      }
      setState(() => status = 'Recorded');
      _showVideoPreview();
    } catch (e) {
      setState(() => status = 'Error: $e');
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video, withData: true);
    if (result != null && result.files.single.bytes != null) {
      pickedBytes = result.files.single.bytes;
      pickedPath = result.files.single.path;
      setState(() => status = 'Picked ${result.files.single.name}');
    }
  }

  Future<void> _upload() async {
    setState(() => status = 'Uploading…');
    try {
      final bytes = kIsWeb ? (recordedBytesWeb ?? pickedBytes) : null;
      final res = await Uploader.uploadMedia(
        endpoint: '/upload/video',
        filePath: kIsWeb ? null : (recordedPath ?? pickedPath),
        bytes: bytes,
        filename: 'pooja_${widget.orderId}.${kIsWeb ? 'webm' : 'mp4'}',
        fieldName: 'file',
        fields: {'order_id': widget.orderId},
      );
      final ok = res.statusCode >= 200 && res.statusCode < 300;
      setState(() => status = ok ? 'Uploaded ✅' : 'Upload failed (${res.statusCode})');
    } catch (e) {
      setState(() => status = 'Upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = (kIsWeb && (recordedBytesWeb != null || pickedBytes != null)) || (!kIsWeb && (recordedPath != null || pickedPath != null));

    return Scaffold(
      appBar: AppBar(title: Text('Pooja • ${widget.orderId}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Record a short video and submit (mobile & web)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_mobile.controller != null && _mobile.controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _mobile.controller!.value.aspectRatio,
                child: CameraPreview(_mobile.controller!),
              ),
            const SizedBox(height: 12),
            // --- Preview ---
            if (kIsWeb)
              VideoPreview(bytes: recordedBytesWeb ?? pickedBytes)
            else
              VideoPreview(filePath: recordedPath ?? pickedPath, bytes: pickedBytes),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _startVideo,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Start Recording'),
                ),
                FilledButton.icon(
                  onPressed: _stopVideo,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Stop'),
                ),
                OutlinedButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Pick Video (Alt)'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Status'),
              subtitle: Text(status),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: hasData ? _showVideoPreview : null,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Preview'),
            ),
            FilledButton.icon(
              onPressed: hasData ? _upload : null,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Submit to Server'),
            )
          ],
        ),
      ),
    );
  }
}
