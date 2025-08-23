import 'dart:ui';

import 'package:better_video_player/src/better_video_player_controller.dart';
import 'package:flutter/material.dart';

class VolumeSheet {
  static OverlayEntry? _overlayEntry;
  static _VolumeSheetController? _controller;

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

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _VolumeSheetWidget(
          controller: controller,
          bottom: bottom,
          right: right,
          onAnimationComplete: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
            _controller = null;
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _controller?.hide();
  }
}

class _VolumeSheetWidget extends StatefulWidget {
  final BetterVideoPlayerController controller;
  final double bottom;
  final double right;
  final VoidCallback onAnimationComplete;

  const _VolumeSheetWidget({
    required this.controller,
    required this.bottom,
    required this.right,
    required this.onAnimationComplete,
  });

  @override
  State<_VolumeSheetWidget> createState() => _VolumeSheetWidgetState();
}

class _VolumeSheetWidgetState extends State<_VolumeSheetWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    VolumeSheet._controller = _VolumeSheetController(this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _hide() {
    _fadeController.reverse().then((_) {
      widget.onAnimationComplete();
    });
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeAnimation,
        _scaleAnimation,
        widget.controller,
      ]),
      builder: (context, child) {
        return Positioned(
          bottom: widget.bottom,
          right: widget.right,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
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
                      child: _buildVolumeSlider(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVolumeSlider() {
    return Stack(
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
            height: widget.controller.volume * 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
        Positioned(
          bottom: widget.controller.volume * 100 - 5,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              double currentVolume = widget.controller.volume;
              double deltaVolume = -details.delta.dy / 100.0;
              double newVolume = (currentVolume + deltaVolume).clamp(0.0, 1.0);
              widget.controller.setVolume(newVolume);
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
    );
  }
}

class _VolumeSheetController {
  final _VolumeSheetWidgetState _state;

  _VolumeSheetController(this._state);

  void hide() {
    _state._hide();
  }
}
