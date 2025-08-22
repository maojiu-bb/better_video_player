import 'dart:ui';

import 'package:better_video_player/src/better_video_player_controller.dart';
import 'package:flutter/material.dart';

class VolumeSheet {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = true;

  static bool get isShow => _overlayEntry != null;

  static void show(
    BuildContext context,
    BetterVideoPlayerController controller,
    double bottom,
    double right,
  ) {
    if (_overlayEntry != null) {
      hide();
    }

    _isVisible = true;

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return AnimatedPositioned(
              bottom: bottom,
              right: right,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Material(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 5,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: 5,
                                height: controller.volume * 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: controller.volume * 100 - 5,
                              left: 0,
                              right: 0,
                              child: GestureDetector(
                                onVerticalDragUpdate: (details) {
                                  double currentVolume = controller.volume;
                                  double deltaVolume =
                                      -details.delta.dy / 100.0;
                                  double newVolume =
                                      (currentVolume + deltaVolume)
                                          .clamp(0.0, 1.0);
                                  controller.setVolume(newVolume);
                                },
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    if (_overlayEntry != null) {
      _isVisible = false;

      Future.delayed(const Duration(milliseconds: 300), () {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isVisible = true;
      });
    }
  }
}
