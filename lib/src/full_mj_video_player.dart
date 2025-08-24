import 'package:mj_video_player/src/mj_video_player_controller.dart';
import 'package:mj_video_player/src/widgets/video_player_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullMJVideoPlayer extends StatefulWidget {
  final MJVideoPlayerController controller;

  const FullMJVideoPlayer({super.key, required this.controller});

  @override
  State<FullMJVideoPlayer> createState() => _FullMJVideoPlayerState();
}

class _FullMJVideoPlayerState extends State<FullMJVideoPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    widget.controller.toggleFullscreen();
    Navigator.of(context).pop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.restoreSystemUIOverlays();
  }

  void _enterPictureInPicture() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => widget.controller.toggleToolbar(),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: VideoPlayerContent(
            controller: widget.controller,
            onToggleFullscreen: _exitFullscreen,
            onClose: _exitFullscreen,
            onPictureInPicture: _enterPictureInPicture,
          ),
        ),
      ),
    );
  }
}
