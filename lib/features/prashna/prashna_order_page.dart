// Keep all your existing imports
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prashna_pooja_app/widgets/themed_buttons.dart';
import 'package:provider/provider.dart';
import 'package:prashna_pooja_app/core/uploader.dart';
import 'package:prashna_pooja_app/util/audio_preview.dart';
import 'package:prashna_pooja_app/services/audio_recorder.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Keep your PrashnaOrderPage, PrashnaOrderView, and _PrashnaOrderViewState
// classes and their logic exactly the same.
// Only the build method in _PrashnaOrderViewState needs to be changed.

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
  // PASTE ALL YOUR EXISTING LOGIC, METHODS, AND STATE VARIABLES HERE...
  // NO CHANGES needed for the logic.

  String status = 'Idle';
  Uint8List? pickedBytes;
  String? pickedPath;

  void _showAudioPreview() {
    // Get the recorder from the provider to show the correct data
    final recorder = Provider.of<AudioRecorderService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2c3e50), // Themed bottom sheet
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
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: kIsWeb
                    ? AudioPreview(bytes: recorder.bytes ?? pickedBytes)
                    : AudioPreview(
                        filePath: recorder.path ?? pickedPath,
                        bytes: pickedBytes),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: Icons.check,
                label: 'Done',
              ),
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
    const backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1a237e), Color(0xFF0d47a1)],
    );

    return Consumer<AudioRecorderService>(
      builder: (context, recorder, child) {
        final isRec = recorder.isRecording;
        final hasData =
            (!kIsWeb && (recorder.path != null || pickedPath != null)) ||
                (kIsWeb && ((recorder.bytes != null) || (pickedBytes != null)));

        return Scaffold(
          appBar: AppBar(
            title: Text('Prashna • ${widget.orderId}',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          backgroundColor: backgroundGradient.colors.first,
          body: Container(
            decoration: const BoxDecoration(gradient: backgroundGradient),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Record your audio response and submit',
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 20),

                // --- Action Buttons ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionButton(
                          onPressed: isRec ? null : _startRec,
                          icon: Icons.mic,
                          label: 'Start',
                          color: Colors.green.shade600),
                      ActionButton(
                          onPressed: isRec ? _stopRec : null,
                          icon: Icons.stop_circle_outlined,
                          label: 'Stop',
                          color: Colors.red.shade600),
                      ActionButton(
                          onPressed: _pickAudio,
                          icon: Icons.upload_file,
                          label: 'Pick Audio',
                          color: Colors.blueGrey.shade600),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- Status Info Card ---
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status',
                                style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12)),
                            Text(status,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Audio Preview ---
                if (hasData)
                  (kIsWeb)
                      ? AudioPreview(bytes: recorder.bytes ?? pickedBytes)
                      : AudioPreview(
                          filePath: recorder.path ?? pickedPath,
                          bytes: pickedBytes),

                const Spacer(),

                // --- Bottom Buttons ---
                SecondaryButton(
                  onPressed: hasData ? _showAudioPreview : null,
                  icon: Icons.play_circle_outline,
                  label: 'Preview Audio',
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  onPressed: hasData ? _upload : null,
                  icon: Icons.cloud_upload_outlined,
                  label: 'Submit to Server',
                ),
              ]
                  .animate(interval: 100.ms)
                  .fadeIn()
                  .slideY(begin: 0.2, curve: Curves.easeOut),
            ),
          ),
        );
      },
    );
  }
}
