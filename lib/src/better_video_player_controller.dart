import 'dart:io';

import 'package:better_video_player/src/utils/better_video_type.dart';
import 'package:better_video_player/src/widgets/volume_sheet.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BetterVideoPlayerController extends ChangeNotifier {
  final String url;
  final BetterVideoType type;
  final bool? showToolbar;
  final bool? loop;
  final List<double>? speeds;
  final bool? autoPlay;
  final double? initialSpeed;
  final double? initialVolume;
  final double? initialPosition;
  final double? aspectRation;

  VideoPlayerController? _videoPlayerController;

  bool _isInitialized = false;

  bool _isDisposed = false;

  bool _isShowToolbar = true;

  bool _isFullscreen = false;

  String? _errorMessage;

  List<double> _playbackSpeeds = [0.5, 1, 1.5, 2, 2.5, 3];

  BetterVideoPlayerController({
    required this.url,
    required this.type,
    this.showToolbar,
    this.loop,
    this.speeds,
    this.autoPlay,
    this.initialSpeed,
    this.initialVolume,
    this.initialPosition,
    this.aspectRation,
  });

  /// [network] create a network video player controller
  factory BetterVideoPlayerController.network(
    String url, {
    bool? showToolbar,
    bool? loop,
    List<double>? speeds,
    bool? autoPlay,
    double? initialSpeed,
    double? initialVolume,
    double? initialPosition,
    double? aspectRation,
  }) {
    return BetterVideoPlayerController(
      url: url,
      type: BetterVideoType.network,
      showToolbar: showToolbar,
      loop: loop,
      speeds: speeds,
      autoPlay: autoPlay,
      initialSpeed: initialSpeed,
      initialVolume: initialVolume,
      initialPosition: initialPosition,
      aspectRation: aspectRation,
    );
  }

  /// [asset] create an asset video player controller
  factory BetterVideoPlayerController.asset(
    String asset, {
    bool? showToolbar,
    bool? loop,
    List<double>? speeds,
    bool? autoPlay,
    double? initialSpeed,
    double? initialVolume,
    double? initialPosition,
    double? aspectRation,
  }) {
    return BetterVideoPlayerController(
      url: asset,
      type: BetterVideoType.asset,
      showToolbar: showToolbar,
      loop: loop,
      initialSpeed: initialSpeed,
      initialVolume: initialVolume,
      initialPosition: initialPosition,
      aspectRation: aspectRation,
      speeds: speeds,
      autoPlay: autoPlay,
    );
  }

  /// [file] create a file video player controller
  factory BetterVideoPlayerController.file(
    String path, {
    bool? showToolbar,
    bool? loop,
    List<double>? speeds,
    bool? autoPlay,
    double? initialSpeed,
    double? initialVolume,
    double? initialPosition,
    double? aspectRation,
  }) {
    return BetterVideoPlayerController(
      url: path,
      type: BetterVideoType.file,
      showToolbar: showToolbar,
      loop: loop,
      speeds: speeds,
      autoPlay: autoPlay,
      initialSpeed: initialSpeed,
      initialVolume: initialVolume,
      initialPosition: initialPosition,
      aspectRation: aspectRation,
    );
  }

  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  bool get isInitialized => _isInitialized;

  bool get isAutoPlay => autoPlay ?? false;

  /// [isBuffering] whether the video is buffering
  bool get isBuffering => _videoPlayerController?.value.isBuffering ?? false;

  /// [isPlaying] whether the video is playing
  bool get isPlaying => _videoPlayerController?.value.isPlaying ?? false;

  /// [isPaused] whether the video is paused
  bool get isPaused => !isPlaying;

  /// [isLooping] whether the video is looping
  bool get isLooping =>
      loop ?? _videoPlayerController?.value.isLooping ?? false;

  /// [isShowToolbar] whether the toolbar is shown
  /// if [showToolbar] is false, the toolbar will be hidden
  /// else, the toolbar will be shown
  bool get isShowToolbar {
    if (showToolbar == false) {
      return false;
    }

    return _isShowToolbar;
  }

  /// [isFullscreen] whether the fullscreen is enabled
  bool get isFullscreen => _isFullscreen;

  /// [hasError] whether the video has an error
  bool get hasError => _videoPlayerController?.value.hasError ?? false;

  /// [errorMessage] the error message
  String? get errorMessage =>
      _errorMessage ?? _videoPlayerController?.value.errorDescription;

  /// [duration] the duration of the video
  Duration get duration =>
      _videoPlayerController?.value.duration ?? Duration.zero;

  /// [position] the position of the video
  Duration get position =>
      _videoPlayerController?.value.position ?? Duration.zero;

  /// [volume] the volume of the video
  double get volume => _videoPlayerController?.value.volume ?? 0;

  /// [speed] the speed of the video
  double get speed => _videoPlayerController?.value.playbackSpeed ?? 1;

  /// [aspectRatio] the aspect ratio of the video
  double get aspectRatio =>
      aspectRation ?? _videoPlayerController?.value.aspectRatio ?? 16 / 9;

  /// [size] the size of the video
  Size get size => _videoPlayerController?.value.size ?? Size.zero;

  List<double> get playbackSpeeds => speeds ?? _playbackSpeeds;

  Future<void> init({Function()? callback}) async {
    if (_isInitialized) return;

    switch (type) {
      case BetterVideoType.network:

        /// [valid] check if the url is a valid url
        if (url.isEmpty ||
            !url.startsWith('http') ||
            !url.startsWith('https')) {
          _errorMessage = 'Invalid URL';
          return;
        }

        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(url),
          httpHeaders: {'User-Agent': 'BetterVideoPlayer'},
        );

        break;

      case BetterVideoType.asset:

        /// [valid] check if the asset is a valid asset
        if (url.isEmpty || !url.startsWith('assets/')) {
          _errorMessage = 'Invalid asset';
          return;
        }

        _videoPlayerController = VideoPlayerController.asset(url);

        break;

      case BetterVideoType.file:

        /// [valid] check if the file is a valid file
        if (url.isEmpty || !File(url).existsSync()) {
          _errorMessage = 'Invalid file';
          return;
        }

        _videoPlayerController = VideoPlayerController.file(File(url));

        break;
    }

    await _videoPlayerController?.setLooping(isLooping);

    _videoPlayerController!.addListener(() {
      _onVideoPlayerListener(callback);
    });

    // Initialize the video player first
    await _videoPlayerController!.initialize();

    // Set initial configurations after initialization
    if (initialSpeed != null) {
      await _videoPlayerController?.setPlaybackSpeed(initialSpeed!);
    }

    if (initialVolume != null) {
      await _videoPlayerController?.setVolume(initialVolume!);
    }

    // Set initial position after initialization is complete
    if (initialPosition != null) {
      await _videoPlayerController?.seekTo(
        Duration(seconds: initialPosition!.toInt()),
      );
    }

    _isInitialized = true;

    _errorMessage = null;

    notifyListeners();
  }

  void _onVideoPlayerListener(Function()? callback) {
    if (!_isDisposed) {
      if (callback != null) {
        callback();
      }

      notifyListeners();
    }
  }

  /// [play] the video
  Future<void> play() async {
    if (_videoPlayerController != null && _isInitialized) {
      await _videoPlayerController!.play();
    }
  }

  /// [pause] the video
  Future<void> pause() async {
    if (_videoPlayerController != null && _isInitialized) {
      await _videoPlayerController!.pause();
    }
  }

  /// [seekTo] the video to the given duration
  void seekTo(Duration duration) {
    if (_videoPlayerController != null && _isInitialized) {
      _videoPlayerController!.seekTo(duration);
      notifyListeners();
    }
  }

  /// [setVolume] the volume of the video
  void setVolume(double volume) {
    volume = volume.clamp(0.0, 1.0);

    if (_videoPlayerController != null && _isInitialized) {
      _videoPlayerController!.setVolume(volume);
      notifyListeners();
    }
  }

  /// [setSpeed] the speed of the video
  Future<void> setSpeed(double speed) async {
    if (_videoPlayerController != null && _isInitialized) {
      await _videoPlayerController!.setPlaybackSpeed(speed);
      notifyListeners();
    }
  }

  /// [setLoop] whether the video should loop
  void setLoop(bool loop) {
    if (_videoPlayerController != null && _isInitialized) {
      _videoPlayerController!.setLooping(loop);
      notifyListeners();
    }
  }

  void setSpeeds(List<double> speeds) {
    if (_videoPlayerController != null && _isInitialized) {
      _playbackSpeeds = speeds;
      notifyListeners();
    }
  }

  /// [toggleToolbar] toggle the toolbar
  void toggleToolbar() {
    if (VolumeSheet.isShow) {
      VolumeSheet.hide();

      notifyListeners();
      return;
    }

    _isShowToolbar = !_isShowToolbar;
    notifyListeners();
  }

  /// [toggleFullscreen] toggle the fullscreen
  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }

  /// [dispose] dispose the video player
  @override
  void dispose() {
    if (_isDisposed) return;

    _videoPlayerController?.removeListener(() {
      _onVideoPlayerListener(null);
    });
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _isDisposed = true;

    debugPrint('better video player controller dispose');

    super.dispose();
  }
}
