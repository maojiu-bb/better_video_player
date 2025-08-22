import 'dart:async';

import 'package:flutter/material.dart';

class BetterVideoProgress extends StatefulWidget {
  final double totalDuration;
  final double currentDuration;
  final Function(double) onSeek;

  const BetterVideoProgress({
    super.key,
    required this.totalDuration,
    required this.currentDuration,
    required this.onSeek,
  });

  @override
  State<BetterVideoProgress> createState() => _BetterVideoProgressState();
}

class _BetterVideoProgressState extends State<BetterVideoProgress> {
  bool _isDragging = false;
  double? _dragPosition;
  Timer? _clearStateTimer;

  @override
  void dispose() {
    super.dispose();

    _clearStateTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final displayDuration = _isDragging && _dragPosition != null
            ? _dragPosition!
            : widget.currentDuration;

        final progressWidth = widget.totalDuration > 0
            ? (displayDuration / widget.totalDuration * constraints.maxWidth)
                .clamp(0.0, constraints.maxWidth)
            : 0.0;

        return GestureDetector(
          onTapUp: (details) {
            if (!_isDragging) {
              final tapX = details.localPosition.dx;
              final tapRatio = (tapX / constraints.maxWidth).clamp(0.0, 1.0);
              final newDuration = tapRatio * widget.totalDuration;

              setState(() {
                _isDragging = true;
                _dragPosition = newDuration;
              });

              widget.onSeek(newDuration);

              _clearStateTimer?.cancel();
              _clearStateTimer = Timer(const Duration(milliseconds: 300), () {
                setState(() {
                  _isDragging = false;
                  _dragPosition = null;
                });
              });
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: constraints.maxWidth,
            height: 10,
            child: Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    width: progressWidth,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned(
                  left: progressWidth - 5,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanStart: (details) {
                      _clearStateTimer?.cancel();
                      setState(() {
                        _isDragging = true;
                        _dragPosition = widget.currentDuration;
                      });
                    },
                    onPanUpdate: (details) {
                      if (_isDragging && _dragPosition != null) {
                        final deltaTime =
                            (details.delta.dx / constraints.maxWidth) *
                                widget.totalDuration;

                        final newPosition = (_dragPosition! + deltaTime).clamp(
                          0.0,
                          widget.totalDuration,
                        );

                        setState(() {
                          _dragPosition = newPosition;
                        });
                      }
                    },
                    onPanEnd: (details) {
                      if (_isDragging && _dragPosition != null) {
                        final finalPosition = _dragPosition!;

                        widget.onSeek(finalPosition);

                        _clearStateTimer?.cancel();
                        _clearStateTimer = Timer(
                          const Duration(milliseconds: 300),
                          () {
                            if (mounted) {
                              setState(() {
                                _isDragging = false;
                                _dragPosition = null;
                              });
                            }
                          },
                        );
                      }
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
        );
      },
    );
  }
}
