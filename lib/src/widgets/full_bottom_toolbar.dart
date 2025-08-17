import 'dart:ui';

import 'package:better_video_player/src/widgets/better_video_progress.dart';
import 'package:better_video_player/src/utils/duration_format.dart';
import 'package:flutter/material.dart';

class FullBottomToolbar extends StatelessWidget {
  final double totalDuration;
  final double currentDuration;
  final double playbackSpeed;
  final Function() onExitFullscreen;
  final Function() onPlaybackSpeed;
  final Function() onVolume;
  final Function(double) onSeek;

  const FullBottomToolbar({
    super.key,
    required this.totalDuration,
    required this.currentDuration,
    required this.onExitFullscreen,
    required this.playbackSpeed,
    required this.onPlaybackSpeed,
    required this.onVolume,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Row(
                children: [
                  Text(
                    durationFormat(currentDuration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "/",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    durationFormat(totalDuration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
              Expanded(
                child: BetterVideoProgress(
                  totalDuration: totalDuration,
                  currentDuration: currentDuration,
                  onSeek: onSeek,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: onPlaybackSpeed,
                child: Text(
                  "${playbackSpeed}x",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: onVolume,
                child: Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: onExitFullscreen,
                child: Icon(
                  Icons.fullscreen_exit_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
