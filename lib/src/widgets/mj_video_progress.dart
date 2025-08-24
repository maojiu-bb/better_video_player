import 'package:flutter/material.dart';

class MJVideoProgress extends StatefulWidget {
  final double totalDuration;
  final double currentDuration;
  final Function(double, VoidCallback?) onSeek;

  const MJVideoProgress({
    super.key,
    required this.totalDuration,
    required this.currentDuration,
    required this.onSeek,
  });

  @override
  State<MJVideoProgress> createState() => _MJVideoProgressState();
}

class _MJVideoProgressState extends State<MJVideoProgress> {
  bool _isDragging = false;
  double? _dragPosition;
  bool _isSeeking = false;
  double? _targetPosition;

  @override
  void didUpdateWidget(MJVideoProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isSeeking && _targetPosition != null) {
      final difference = (widget.currentDuration - _targetPosition!).abs();
      if (difference < 0.5) {
        setState(() {
          _isSeeking = false;
          _targetPosition = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final displayDuration = _isDragging && _dragPosition != null
            ? _dragPosition!
            : _isSeeking && _targetPosition != null
                ? _targetPosition!
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
                _isSeeking = true;
                _targetPosition = newDuration;
              });

              widget.onSeek(newDuration, () {});
            }
          },
          onPanStart: (details) {
            setState(() {
              _isDragging = true;
              _dragPosition = widget.currentDuration;
              _isSeeking = false;
              _targetPosition = null;
            });
          },
          onPanUpdate: (details) {
            if (_isDragging && _dragPosition != null) {
              final deltaTime = (details.delta.dx / constraints.maxWidth) *
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

              setState(() {
                _isDragging = false;
                _dragPosition = null;
                _isSeeking = true;
                _targetPosition = finalPosition;
              });

              widget.onSeek(finalPosition, () {});
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
              ],
            ),
          ),
        );
      },
    );
  }
}
