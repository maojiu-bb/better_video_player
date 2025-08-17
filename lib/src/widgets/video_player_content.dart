import 'dart:ui';
import 'package:better_video_player/src/better_video_player_controller.dart';
import 'package:better_video_player/src/widgets/better_error_widget.dart';
import 'package:better_video_player/src/widgets/full_bottom_toolbar.dart';
import 'package:better_video_player/src/widgets/speed_sheet.dart';
import 'package:better_video_player/src/widgets/standard_bottom_toolbar.dart';
import 'package:better_video_player/src/widgets/top_toolbar.dart';
import 'package:better_video_player/src/widgets/volume_sheet.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerContent extends StatelessWidget {
  final BetterVideoPlayerController controller;
  final Function() onFullscreen;
  final Function()? onClose;
  final Function()? onPictureInPicture;

  const VideoPlayerContent({
    super.key,
    required this.controller,
    required this.onFullscreen,
    this.onClose,
    this.onPictureInPicture,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (controller.hasError) {
          return BetterErrorWidget(
            errorMessage: controller.errorMessage ?? 'Error',
            onRefresh: () => controller.init(),
          );
        }

        if (controller.isInitialized) {
          return Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller.videoPlayerController!),

              _buildCenterPlayButton(),

              _buildBottomToolbar(context),

              if (controller.isFullscreen) _buildTopToolbar(),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildCenterPlayButton() {
    return AnimatedOpacity(
      opacity: controller.isShowToolbar ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          if (controller.isShowToolbar) {
            controller.isPlaying ? controller.pause() : controller.play();
          }
        },
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                controller.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    return Positioned(
      left: controller.isFullscreen ? 40 : 20,
      right: controller.isFullscreen ? 40 : 20,
      bottom: 10,
      child: AnimatedOpacity(
        opacity: controller.isShowToolbar ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child:
            controller.isFullscreen
                ? FullBottomToolbar(
                  totalDuration: controller.duration.inSeconds.toDouble(),
                  currentDuration: controller.position.inSeconds.toDouble(),
                  onExitFullscreen: () {
                    if (controller.isShowToolbar) {
                      onFullscreen();
                    }
                  },
                  playbackSpeed: controller.speed,
                  onPlaybackSpeed: () {
                    if (controller.isShowToolbar) {
                      _showPlaybackSpeedSheet(context);
                    }
                  },
                  onVolume: () {
                    if (controller.isShowToolbar) {
                      _showVolumeSheet(context);
                    }
                  },
                  onSeek: (double newDuration) {
                    if (controller.isShowToolbar) {
                      controller.seekTo(Duration(seconds: newDuration.toInt()));
                    }
                  },
                )
                : StandardBottomToolbar(
                  totalDuration: controller.duration.inSeconds.toDouble(),
                  currentDuration: controller.position.inSeconds.toDouble(),
                  onFullscreen: () {
                    if (controller.isShowToolbar) {
                      onFullscreen();
                    }
                  },
                  onSeek: (newDuration) {
                    if (controller.isShowToolbar) {
                      controller.seekTo(Duration(seconds: newDuration.toInt()));
                    }
                  },
                ),
      ),
    );
  }

  void _showVolumeSheet(BuildContext context) {
    if (controller.isShowToolbar && !VolumeSheet.isShow) {
      final right = 80.0;
      final bottom = 55.0;
      VolumeSheet.show(context, controller, bottom, right);
    }
  }

  void _showPlaybackSpeedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return SpeedSheet(controller: controller);
      },
    );
  }

  Widget _buildTopToolbar() {
    return Positioned(
      top: 20,
      left: 40,
      right: 40,
      child: AnimatedOpacity(
        opacity: controller.isShowToolbar ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: TopToolbar(
          onClose: () {
            if (controller.isShowToolbar) {
              onClose?.call();
            }
          },
          onPictureInPicture: () {
            if (controller.isShowToolbar) {
              onPictureInPicture?.call();
            }
          },
        ),
      ),
    );
  }
}
