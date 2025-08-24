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
  final Function() onToggleFullscreen;
  final Function()? onClose;
  final Function()? onPictureInPicture;

  const VideoPlayerContent({
    super.key,
    required this.controller,
    required this.onToggleFullscreen,
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
              AspectRatio(
                aspectRatio:
                    controller.videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(controller.videoPlayerController!),
              ),
              _buildCenterPlayButton(),
              _buildBottomToolbar(context),
              if (controller.isFullscreen) _buildTopToolbar(),
            ],
          );
        } else {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
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
              child: controller.isBuffering
                  ? SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    )
                  : Icon(
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
      bottom: controller.isFullscreen ? 20 : 10,
      child: SafeArea(
        bottom: false,
        child: AnimatedOpacity(
          opacity: controller.isShowToolbar ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: controller.isFullscreen
              ? FullBottomToolbar(
                  totalDuration: controller.duration.inSeconds.toDouble(),
                  currentDuration: controller.position.inSeconds.toDouble(),
                  onExitFullscreen: () {
                    if (controller.isShowToolbar) {
                      if (VolumeSheet.isShow) {
                        VolumeSheet.hide();
                      }
                      onToggleFullscreen();
                    }
                  },
                  playbackSpeed: controller.speed,
                  onPlaybackSpeed: () {
                    if (controller.isShowToolbar) {
                      _toggleShowPlaybackSpeedSheet(context);
                    }
                  },
                  onVolume: (right, bottom) {
                    if (controller.isShowToolbar) {
                      _toggleShowVolumeSheet(context, right, bottom);
                    }
                  },
                  onSeek: (double newDuration, VoidCallback? onComplete) {
                    if (controller.isShowToolbar) {
                      controller.seekTo(
                        Duration(seconds: newDuration.toInt()),
                      );
                      onComplete?.call();
                    }
                  },
                )
              : StandardBottomToolbar(
                  totalDuration: controller.duration.inSeconds.toDouble(),
                  currentDuration: controller.position.inSeconds.toDouble(),
                  onFullscreen: () {
                    if (controller.isShowToolbar) {
                      onToggleFullscreen();
                    }
                  },
                  onSeek: (newDuration, VoidCallback? onComplete) async {
                    if (controller.isShowToolbar) {
                      await controller.seekTo(
                        Duration(seconds: newDuration.toInt()),
                      );
                      onComplete?.call();
                    }
                  },
                ),
        ),
      ),
    );
  }

  void _toggleShowVolumeSheet(
      BuildContext context, double right, double bottom) {
    if (!VolumeSheet.isShow) {
      VolumeSheet.show(context, controller, bottom, right);
    } else {
      VolumeSheet.hide();
    }
  }

  void _toggleShowPlaybackSpeedSheet(BuildContext context) {
    if (VolumeSheet.isShow) {
      VolumeSheet.hide();
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
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
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: controller.isShowToolbar ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: TopToolbar(
            onClose: () {
              if (controller.isShowToolbar) {
                if (VolumeSheet.isShow) {
                  VolumeSheet.hide();
                }
                onClose?.call();
              }
            },
            // onPictureInPicture: () {
            //   if (controller.isShowToolbar) {
            //     onPictureInPicture?.call();
            //   }
            // },
          ),
        ),
      ),
    );
  }
}
