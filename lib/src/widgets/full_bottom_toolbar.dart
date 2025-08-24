import 'dart:ui';

import 'package:mj_video_player/src/widgets/mj_video_progress.dart';
import 'package:mj_video_player/src/utils/duration_format.dart';
import 'package:flutter/material.dart';

class FullBottomToolbar extends StatefulWidget {
  final double totalDuration;
  final double currentDuration;
  final double playbackSpeed;
  final Function() onExitFullscreen;
  final Function() onPlaybackSpeed;
  final Function(double right, double bottom) onVolume;
  final Function(double, VoidCallback?) onSeek;

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
  State<FullBottomToolbar> createState() => _FullBottomToolbarState();
}

class _FullBottomToolbarState extends State<FullBottomToolbar> {
  final GlobalKey _volumeKey = GlobalKey();

  List<double> _calculateRightAndBottom() {
    final RenderBox renderBox =
        _volumeKey.currentContext?.findRenderObject() as RenderBox;

    final offset = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    const volumeSheetWidth = 35.0;
    const spacing = 10.0;

    final buttonCenterX = offset.dx + buttonSize.width / 2;
    final sheetLeftEdge = buttonCenterX - volumeSheetWidth / 2;
    final rightDistance = screenSize.width - sheetLeftEdge - volumeSheetWidth;

    final buttonTopY = offset.dy;
    final sheetBottomEdge = buttonTopY - spacing;
    final bottomDistance = screenSize.height - sheetBottomEdge;

    return [rightDistance, bottomDistance];
  }

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
                    durationFormat(widget.currentDuration),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Text(
                    "/",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    durationFormat(widget.totalDuration),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MJVideoProgress(
                  totalDuration: widget.totalDuration,
                  currentDuration: widget.currentDuration,
                  onSeek: widget.onSeek,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: widget.onPlaybackSpeed,
                child: Text(
                  "${widget.playbackSpeed}x",
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                key: _volumeKey,
                onTap: () {
                  final [right, bottom] = _calculateRightAndBottom();
                  widget.onVolume(right, bottom);
                },
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: widget.onExitFullscreen,
                child: const Icon(
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
