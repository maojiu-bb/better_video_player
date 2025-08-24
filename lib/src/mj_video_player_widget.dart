import 'package:mj_video_player/src/mj_video_player_controller.dart';
import 'package:mj_video_player/src/full_mj_video_player.dart';
import 'package:mj_video_player/src/widgets/video_player_content.dart';
import 'package:flutter/material.dart';

class MJVideoPlayer extends StatefulWidget {
  final MJVideoPlayerController controller;

  const MJVideoPlayer({super.key, required this.controller});

  @override
  State<MJVideoPlayer> createState() => _MJVideoPlayerState();
}

class _MJVideoPlayerState extends State<MJVideoPlayer> {
  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    await widget.controller.init();

    if (widget.controller.isAutoPlay) {
      widget.controller.play();
    }
  }

  void _navigateToFullscreen() {
    widget.controller.toggleFullscreen();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullMJVideoPlayer(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.controller.toggleToolbar(),
      child: Container(
        color: Colors.black,
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: widget.controller.aspectRatio,
          child: VideoPlayerContent(
            controller: widget.controller,
            onToggleFullscreen: _navigateToFullscreen,
          ),
        ),
      ),
    );
  }
}
