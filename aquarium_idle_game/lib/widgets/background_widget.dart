import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BackgroundWidget extends StatefulWidget {
  final String animationPath = 'assets/animations/background/background.json';
  final double speed;

  const BackgroundWidget({
    Key? key,
    this.speed = 1.0,
  }) : super(key: key);

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Make animation 30% faster
    int fastDuration = ((_controller.duration?.inMilliseconds ?? 5000) / (widget.speed)).round();
    _controller.duration = Duration(milliseconds: fastDuration);

    // Play animation immediately
    _playAnimationCycle();
  }

  void _playAnimationCycle() {
    // Play the animation once
    _controller.forward(from: 0).then((_) {
      if (mounted) {
        // Wait until 10 seconds total before playing again
        _animationTimer = Timer(
            Duration(milliseconds: 10000 - _controller.duration!.inMilliseconds),
                () {
              if (mounted) {
                _controller.reset();
                _playAnimationCycle();
              }
            }
        );
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Lottie.asset(
        widget.animationPath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        frameRate: const FrameRate(50),
        controller: _controller,
      ),
    );
  }
}