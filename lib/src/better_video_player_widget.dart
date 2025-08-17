import 'package:better_video_player/src/better_video_player_controller.dart';
import 'package:better_video_player/src/full_better_video_player.dart';
import 'package:better_video_player/src/widgets/video_player_content.dart';
import 'package:flutter/material.dart';

class BetterVideoPlayer extends StatefulWidget {
  final BetterVideoPlayerController controller;

  const BetterVideoPlayer({super.key, required this.controller});

  @override
  State<BetterVideoPlayer> createState() => _BetterVideoPlayerState();
}

class _BetterVideoPlayerState extends State<BetterVideoPlayer> {
  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    await widget.controller.init();
  }

  void _navigateToFullscreen() {
    widget.controller.toggleFullscreen();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => FullBetterVideoPlayer(controller: widget.controller),
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
          aspectRatio: 16 / 9,
          child: VideoPlayerContent(
            controller: widget.controller,
            onFullscreen: _navigateToFullscreen,
          ),
        ),
      ),
    );
  }
}
