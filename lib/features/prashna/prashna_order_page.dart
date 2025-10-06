import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:prashna_pooja_app/core/uploader.dart';
import 'package:prashna_pooja_app/util/audio_preview.dart';
import 'package:prashna_pooja_app/services/audio_recorder.dart';

class PrashnaOrderPage extends StatelessWidget {
  // Can become a StatelessWidget
  final String orderId;
  const PrashnaOrderPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Provide the AudioRecorderService to the widget tree below.
    // The provider handles creating and disposing the service for you.
    return ChangeNotifierProvider(
      create: (_) => AudioRecorderService(),
      child: PrashnaOrderView(orderId: orderId), // The actual UI
    );
  }
}

// We moved your original StatefulWidget's content into a new widget.
class PrashnaOrderView extends StatefulWidget {
  final String orderId;
  const PrashnaOrderView({super.key, required this.orderId});

  @override
  State<PrashnaOrderView> createState() => _PrashnaOrderViewState();
}

class _PrashnaOrderViewState extends State<PrashnaOrderView> {
  // We no longer need to manage the recorder instance or its lifecycle here.
  // The provider does it for us.

  String status = 'Idle';
  Uint8List? pickedBytes;
  String? pickedPath;

  void _showAudioPreview() {
    // Get the recorder from the provider to show the correct data
    final recorder = Provider.of<AudioRecorderService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Preview audio',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: kIsWeb
                    ? AudioPreview(bytes: recorder.bytes ?? pickedBytes)
                    : AudioPreview(
                        filePath: recorder.path ?? pickedPath,
                        bytes: pickedBytes),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Done'),
              )
            ],
          ),
        );
      },
    );
  }

  // Helper methods now get the recorder via Provider.of
  Future<void> _startRec() async {
    final recorder = Provider.of<AudioRecorderService>(context, listen: false);
    try {
      setState(() => status = 'Recording…');
      await recorder.start();
    } catch (e) {
      setState(() => status = 'Error: $e');
    }
  }

  Future<void> _stopRec() async {
    final recorder = Provider.of<AudioRecorderService>(context, listen: false);
    try {
      await recorder.stop();
      setState(() => status = 'Recorded');
      _showAudioPreview();
    } catch (e) {
      setState(() => status = 'Error: $e');
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.audio, withData: true);
    if (result != null && result.files.single.bytes != null) {
      pickedBytes = result.files.single.bytes;
      pickedPath = result.files.single.path;
      setState(() => status = 'Picked ${result.files.single.name}');
    }
  }

  Future<void> _upload() async {
    final recorder = Provider.of<AudioRecorderService>(context, listen: false);
    setState(() => status = 'Uploading…');
    try {
      final bytes = kIsWeb ? (recorder.bytes ?? pickedBytes) : null;
      final res = await Uploader.uploadMedia(
        endpoint: '/upload/audio',
        filePath: kIsWeb ? null : (recorder.path ?? pickedPath),
        bytes: bytes,
        filename: 'prashna_${widget.orderId}.${kIsWeb ? 'wav' : 'm4a'}',
        fieldName: 'file',
        fields: {'order_id': widget.orderId},
      );
      final ok = res.statusCode >= 200 && res.statusCode < 300;
      setState(() =>
          status = ok ? 'Uploaded ✅' : 'Upload failed (${res.statusCode})');
    } catch (e) {
      setState(() => status = 'Upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer widget listens to the AudioRecorderService and rebuilds
    // its child widget tree whenever notifyListeners() is called.
    return Consumer<AudioRecorderService>(
      builder: (context, recorder, child) {
        // Get the state directly from the 'recorder' instance
        final isRec = recorder.isRecording;
        final hasData =
            (!kIsWeb && (recorder.path != null || pickedPath != null)) ||
                (kIsWeb && ((recorder.bytes != null) || (pickedBytes != null)));

        return Scaffold(
          appBar: AppBar(title: Text('Prashna • ${widget.orderId}')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Record your audio response and submit (mobile & web)',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isRec ? null : _startRec,
                      icon: const Icon(Icons.mic),
                      label: const Text('Start Recording'),
                    ),
                    FilledButton.icon(
                      onPressed: isRec ? _stopRec : null,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('Stop'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickAudio,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Pick Audio (Alt)'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Status'),
                  subtitle: Text(status),
                ),
                const SizedBox(height: 8),
                if (kIsWeb)
                  AudioPreview(bytes: recorder.bytes ?? pickedBytes)
                else
                  AudioPreview(
                      filePath: recorder.path ?? pickedPath,
                      bytes: pickedBytes),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: hasData ? _showAudioPreview : null,
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
      },
    );
  }
}
