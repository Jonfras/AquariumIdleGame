
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../model/decoration.dart' as model;

class AnimatedDecoration extends StatefulWidget {
  final model.Decoration decoration;
  final Offset? position;
  final bool isPreview;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AnimatedDecoration({
    Key? key,
    required this.decoration,
    this.position,
    this.isPreview = false,
    this.errorBuilder,
  }) : super(key: key);

  @override
  _AnimatedDecorationState createState() => _AnimatedDecorationState();
}

class _AnimatedDecorationState extends State<AnimatedDecoration> {
  @override
  Widget build(BuildContext context) {
    if (widget.isPreview) {
      // Preview mode - static decoration
      return SizedBox(
        width: 80,
        height: 80,
        child: Lottie.asset(
          widget.decoration.assetPath,
          fit: BoxFit.contain,
          frameRate: const FrameRate(24),
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(['**'], value: widget.decoration.color),
            ],
          ),
          errorBuilder: widget.errorBuilder ?? (context, error, stackTrace) {
            return Icon(Icons.landscape, color: widget.decoration.color, size: 50);
          },
        ),
      );
    }

    // Normal mode - positioned decoration
    return Positioned(
      left: widget.position?.dx ?? 0,
      bottom: widget.position?.dy ?? 0,
      child: SizedBox(
        width: widget.decoration.size * 100,
        height: widget.decoration.size * 100,
        child: Lottie.asset(
          widget.decoration.assetPath,
          fit: BoxFit.contain,
          frameRate: const FrameRate(24),
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(['**'], value: widget.decoration.color),
            ],
          ),
          errorBuilder: widget.errorBuilder ?? (context, error, stackTrace) {
            return Icon(Icons.landscape, color: widget.decoration.color, size: 50);
          },
        ),
      ),
    );
  }
}