import 'dart:ui';

import 'package:better_video_player/src/widgets/better_video_progress.dart';
import 'package:better_video_player/src/utils/duration_format.dart';
import 'package:flutter/material.dart';

class StandardBottomToolbar extends StatelessWidget {
  final double totalDuration;
  final double currentDuration;
  final Function() onFullscreen;
  final Function(double, VoidCallback?) onSeek;

  const StandardBottomToolbar({
    super.key,
    required this.totalDuration,
    required this.currentDuration,
    required this.onFullscreen,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Text(
                    "/",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    durationFormat(totalDuration),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BetterVideoProgress(
                  totalDuration: totalDuration,
                  currentDuration: currentDuration,
                  onSeek: onSeek,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onFullscreen,
                child: const Icon(
                  Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
