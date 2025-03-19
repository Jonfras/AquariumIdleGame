import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:math';

import '../model/fish.dart';

class AnimatedFish extends StatefulWidget {
  final Fish fish;

  const AnimatedFish({Key? key, required this.fish}) : super(key: key);

  @override
  _AnimatedFishState createState() => _AnimatedFishState();
}

class _AnimatedFishState extends State<AnimatedFish>
    with TickerProviderStateMixin {
  late AnimationController _horizontalController;
  late AnimationController _verticalController;
  late Animation<double> _horizontalAnimation;
  late Animation<double> _verticalAnimation;
  bool _isInitialized = false;
  double _currentLeft = 0.0;
  double _currentTop = 0.0;
  bool _swimmingRight = true;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized && mounted) {
        _initializeAnimations();
      }
    });
  }

  void _initializeAnimations() {
    try {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final fishSize = widget.fish.size * 100;

      // Set initial position - start at the left edge
      _currentLeft = _random.nextDouble() * (screenWidth / 2);
      _currentTop = 100 + _random.nextDouble() * (screenHeight - fishSize - 200);
      _swimmingRight = true;

      // Initialize controllers
      _horizontalController = AnimationController(
        duration: Duration(milliseconds: 3000 + _random.nextInt(2000)),
        vsync: this,
      );

      _verticalController = AnimationController(
        duration: const Duration(seconds: 5),
        vsync: this,
      );

      _createHorizontalAnimation(screenWidth, fishSize);
      _createVerticalAnimation();

      _isInitialized = true;

      // Start vertical bobbing immediately and repeat forever
      _verticalController.repeat(reverse: true);

      // Listen for horizontal animation completion to change direction
      _horizontalController.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            // Update current position
            _currentLeft = _swimmingRight ? screenWidth - fishSize - 20 : 20;

            // Change direction
            _swimmingRight = !_swimmingRight;

            // Create new horizontal animation
            _createHorizontalAnimation(screenWidth, fishSize);

            // Start new animation
            _horizontalController.reset();
            _horizontalController.forward();
          });

          debugPrint(
            'Fish ${widget.fish.type} changing direction to: ${_swimmingRight ? "right" : "left"}',
          );
        }
      });

      // Start swimming
      _horizontalController.forward();

      debugPrint(
        'Fish animation initialized for ${widget.fish.type} at position: $_currentLeft, $_currentTop',
      );
    } catch (e) {
      debugPrint('Error initializing fish animation: $e');
    }
  }

  void _createHorizontalAnimation(double screenWidth, double fishSize) {
    final targetX =
        _swimmingRight
            ? screenWidth -
                fishSize -
                20 // Right edge with padding
            : 20; // Left edge with padding

    _horizontalAnimation = Tween<double>(
      begin: _currentLeft,
      end: targetX.toDouble(),
    ).animate(
      CurvedAnimation(parent: _horizontalController, curve: Curves.linear),
    );
  }

  void _createVerticalAnimation() {
    // Small vertical bobbing motion
    _verticalAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _verticalController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    final fishSize = widget.fish.size * 100;

    return AnimatedBuilder(
      animation: Listenable.merge([_horizontalController, _verticalController]),
      builder: (context, child) {
        final currentLeft = _horizontalAnimation.value;
        final verticalOffset = _verticalAnimation.value;
        final currentTop = _currentTop + verticalOffset;

        return Positioned(
          left: currentLeft,
          top: currentTop,
          child: Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..scale(_swimmingRight ? 1.0 : -1.0, 1.0, 1.0),
            child: Stack(
              children: [
                // Fish visualization
                SizedBox(
                  width: fishSize,
                  height: fishSize,
                  child: Lottie.asset(
                    widget.fish.assetPath,
                    width: fishSize,
                    height: fishSize,
                    fit: BoxFit.contain,
                    frameRate: const FrameRate(24),
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(['**'], value: widget.fish.color),
                      ],
                    ),
                  ),
                ),

                // Debug outline - uncomment to see fish boundaries
                /*Container(
                  width: fishSize,
                  height: fishSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                ),*/
              ],
            ),
          ),
        );
      },
    );
  }
}
