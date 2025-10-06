import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class AudioCaptureResult {
  final String? path; // mobile path
  final Uint8List? bytes; // web bytes (WAV)
  AudioCaptureResult({this.path, this.bytes});
}

class AudioRecorderService with ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  String? _path;
  Uint8List? _bytes;

  // Web stream handling
  StreamSubscription<Uint8List>? _streamSub;
  final BytesBuilder _pcmChunks = BytesBuilder(copy: false);
  final int _sampleRate = 44100;
  final int _channels = 1;

  bool get isRecording => _isRecording;
  String? get path => _path;
  Uint8List? get bytes => _bytes;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> start() async {
    _bytes = null;
    _path = null;

    if (!await hasPermission()) {
      throw Exception('Microphone permission denied');
    }

    if (kIsWeb) {
      _pcmChunks.clear();
      final stream = await _recorder.startStream(RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: _channels,
      ));
      _streamSub = stream.listen((chunk) => _pcmChunks.add(chunk));
    } else {
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: _sampleRate,
          numChannels: _channels,
          bitRate: 128000,
        ),
        path: '',
      );
    }

    _isRecording = true;
    notifyListeners();
  }

  Future<AudioCaptureResult> stop() async {
    if (!_isRecording) {
      throw Exception('Not recording');
    }

    if (kIsWeb) {
      await _streamSub?.cancel();
      await _recorder.stop(); // finalize
      final pcm = _pcmChunks.toBytes();
      _bytes = _pcm16ToWav(pcm, _sampleRate, _channels);
      _isRecording = false;
      notifyListeners();
      return AudioCaptureResult(bytes: _bytes);
    } else {
      _path = await _recorder.stop();
      _isRecording = false;
      notifyListeners();
      return AudioCaptureResult(path: _path);
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // ---- WAV encoder (PCM16) ----
  Uint8List _pcm16ToWav(Uint8List pcm16, int sampleRate, int channels) {
    final byteRate = sampleRate * channels * 2;
    final blockAlign = channels * 2;
    final dataSize = pcm16.lengthInBytes;
    final chunkSize = 36 + dataSize;

    final header = BytesBuilder();
    header.add(asciiBytes("RIFF"));
    header.add(_le32(chunkSize));
    header.add(asciiBytes("WAVE"));
    header.add(asciiBytes("fmt "));
    header.add(_le32(16)); // Subchunk1Size (16 for PCM)
    header.add(_le16(1)); // AudioFormat (1 = PCM)
    header.add(_le16(channels)); // NumChannels
    header.add(_le32(sampleRate)); // SampleRate
    header.add(_le32(byteRate)); // ByteRate
    header.add(_le16(blockAlign)); // BlockAlign
    header.add(_le16(16)); // BitsPerSample
    header.add(asciiBytes("data"));
    header.add(_le32(dataSize));

    final out = BytesBuilder(copy: false);
    out.add(header.toBytes());
    out.add(pcm16);
    return out.toBytes();
  }

  Uint8List _le16(int value) =>
      Uint8List(2)..buffer.asByteData().setUint16(0, value, Endian.little);
  Uint8List _le32(int value) =>
      Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little);
  Uint8List asciiBytes(String s) => Uint8List.fromList(s.codeUnits);
}
