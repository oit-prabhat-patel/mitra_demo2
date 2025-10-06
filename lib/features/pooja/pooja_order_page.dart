// Keep all your existing imports
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prashna_pooja_app/core/uploader.dart';
import 'package:prashna_pooja_app/util/video_preview.dart';
import 'package:prashna_pooja_app/services/video_recorder.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:prashna_pooja_app/widgets/themed_buttons.dart';

class PoojaOrderPage extends StatefulWidget {
  final String orderId;
  const PoojaOrderPage({super.key, required this.orderId});

  @override
  State<PoojaOrderPage> createState() => _PoojaOrderPageState();
}

class _PoojaOrderPageState extends State<PoojaOrderPage> {
  // ... (ALL YOUR EXISTING LOGIC, METHODS, AND STATE VARIABLES GO HERE)
  // _showVideoPreview, _mobile, pickedBytes, status, _startVideo, etc.
  // NO CHANGES needed for the logic.

  // PASTE ALL YOUR EXISTING METHODS AND VARIABLES HERE...
  void _showVideoPreview() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2c3e50), // Themed bottom sheet
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final preview = kIsWeb
            ? VideoPreview(bytes: recordedBytesWeb ?? pickedBytes)
            : VideoPreview(
                filePath: recordedPath ?? pickedPath, bytes: pickedBytes);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Preview video',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(height: 260, child: preview)),
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
    final result = await FilePicker.platform
        .pickFiles(type: FileType.video, withData: true);
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
      setState(() =>
          status = ok ? 'Uploaded ✅' : 'Upload failed (${res.statusCode})');
    } catch (e) {
      setState(() => status = 'Upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData =
        (kIsWeb && (recordedBytesWeb != null || pickedBytes != null)) ||
            (!kIsWeb && (recordedPath != null || pickedPath != null));
    const backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1a237e), Color(0xFF0d47a1)],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Pooja • ${widget.orderId}', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: backgroundGradient.colors.first,
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Record a short video and submit',
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),

              // --- Camera/Video Preview ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: (_mobile.controller != null &&
                            _mobile.controller!.value.isInitialized)
                        ? AspectRatio(
                            aspectRatio: _mobile.controller!.value.aspectRatio,
                            child: CameraPreview(_mobile.controller!),
                          )
                        : (hasData
                            ? (kIsWeb
                                ? VideoPreview(
                                    bytes: recordedBytesWeb ?? pickedBytes)
                                : VideoPreview(
                                    filePath: recordedPath ?? pickedPath,
                                    bytes: pickedBytes))
                            : AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Center(
                                  child: Text('Camera preview will appear here',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white54)),
                                ),
                              ))),
              ),
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
                        onPressed: _startVideo,
                        icon: Icons.videocam,
                        label: 'Start',
                        color: Colors.green.shade600),
                    ActionButton(
                        onPressed: _stopVideo,
                        icon: Icons.stop_circle_outlined,
                        label: 'Stop',
                        color: Colors.red.shade600),
                    ActionButton(
                        onPressed: _pickVideo,
                        icon: Icons.upload_file,
                        label: 'Pick Video',
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
              const SizedBox(height: 40),

              // --- Bottom Buttons ---
              SecondaryButton(
                onPressed: hasData ? _showVideoPreview : null,
                icon: Icons.play_circle_outline,
                label: 'Preview Video',
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
      ),
    );
  }
}
