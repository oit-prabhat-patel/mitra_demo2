import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPreview extends StatefulWidget {
  final String? filePath;
  final Uint8List? bytes;
  const AudioPreview({super.key, this.filePath, this.bytes});

  @override
  State<AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<AudioPreview> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPositionChanged.listen((d) => setState(() => _pos = d));
    _player.onDurationChanged.listen((d) => setState(() => _dur = d));
    _player.onPlayerStateChanged
        .listen((s) => setState(() => _isPlaying = s == PlayerState.playing));
  }

  Future<void> _loadAndPlay() async {
    if (widget.filePath != null) {
      await _player.play(DeviceFileSource(widget.filePath!));
    } else if (widget.bytes != null) {
      await _player.play(BytesSource(widget.bytes!));
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 36),
              onPressed: () async {
                if (_isPlaying) {
                  await _player.pause();
                } else {
                  await _loadAndPlay();
                }
              },
            ),
            Expanded(
              child: Slider(
                value: _pos.inMilliseconds
                    .clamp(0, _dur.inMilliseconds)
                    .toDouble(),
                max: (_dur.inMilliseconds == 0 ? 1 : _dur.inMilliseconds)
                    .toDouble(),
                onChanged: (v) =>
                    _player.seek(Duration(milliseconds: v.toInt())),
              ),
            ),
            Text("${_pos.inSeconds}/${_dur.inSeconds}s"),
          ],
        ),
      ],
    );
  }
}
