import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCaptureResult {
  final String? path; // mobile path
  final List<int>? bytes; // web bytes
  VideoCaptureResult({this.path, this.bytes});
}

class MobileVideoRecorder {
  CameraController? controller;

  Future<void> init() async {
    if (!kIsWeb) {
      final cam = await Permission.camera.request();
      final mic = await Permission.microphone.request();
      if (!cam.isGranted || !mic.isGranted) {
        throw Exception('Camera/Microphone permission denied');
      }
    }
    final cameras = await availableCameras();
    final CameraDescription first = cameras.first;
    controller = CameraController(first, ResolutionPreset.medium, enableAudio: true);
    await controller!.initialize();
  }

  Future<void> start() async {
    if (controller == null) await init();
    await controller!.startVideoRecording();
  }

  Future<VideoCaptureResult> stop() async {
    final XFile file = await controller!.stopVideoRecording();
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return VideoCaptureResult(bytes: bytes);
    } else {
      return VideoCaptureResult(path: file.path);
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
