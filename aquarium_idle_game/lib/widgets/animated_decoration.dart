
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../model/decoration.dart' as model;

class AnimatedDecoration extends StatefulWidget {
  final model.Decoration decoration;
  final Offset position; // Position in the aquarium

  const AnimatedDecoration({
    Key? key,
    required this.decoration,
    required this.position,
  }) : super(key: key);

  @override
  _AnimatedDecorationState createState() => _AnimatedDecorationState();
}

class _AnimatedDecorationState extends State<AnimatedDecoration> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      bottom: widget.position.dy,
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
        ),
      ),
    );
  }
}