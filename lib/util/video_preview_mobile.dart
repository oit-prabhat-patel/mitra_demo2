import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class VideoPreview extends StatefulWidget {
  final String? filePath;
  final Uint8List? bytes;
  const VideoPreview({super.key, this.filePath, this.bytes});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? _controller;
  File? _tempFile;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.filePath != null) {
      _controller = VideoPlayerController.file(File(widget.filePath!));
    } else if (widget.bytes != null) {
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/preview_${DateTime.now().microsecondsSinceEpoch}.mp4');
      await f.writeAsBytes(widget.bytes!, flush: true);
      _tempFile = f;
      _controller = VideoPlayerController.file(f);
    }
    await _controller?.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    if (_tempFile != null && _tempFile!.existsSync()) {
      _tempFile!.deleteSync();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(_controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 36),
              onPressed: () async {
                if (_controller!.value.isPlaying) {
                  await _controller!.pause();
                } else {
                  await _controller!.play();
                }
                setState(() {});
              },
            ),
            Expanded(
              child: VideoProgressIndicator(_controller!, allowScrubbing: true),
            ),
          ],
        )
      ],
    );
  }
}
