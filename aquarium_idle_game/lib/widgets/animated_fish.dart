import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'dart:async'; // Für Timer
import 'dart:math';

import '../model/fish.dart'; // Für Zufälligkeit

class AnimatedFish extends StatefulWidget {
  Fish fish;
  AnimatedFish({
    Key? key,
    required this.fish,
    
  }) : super(key: key);

  @override
  _AnimatedFishState createState() => _AnimatedFishState();
}

class _AnimatedFishState extends State<AnimatedFish> with SingleTickerProviderStateMixin {
  AnimationController? _globalController;
  Animation<double>? _positionAnimation;
  Animation<double>? _rotationAnimation;
  Animation<double>? _verticalAnimation; // Für vertikale Bewegung
  bool _isInitialized = false;
  Timer? _timer; // Timer für die 10-Sekunden-Verzögerung
  double _currentLeft = 0.0; // Aktuelle horizontale Position
  double _currentTop = 0.0; // Aktuelle vertikale Position
  final Random _random = Random(); // Für zufällige Pfade
  bool _movingRight = true; // Richtung des Fisches (rechts oder links)

  double _getFishSize(int index) {
    const baseSize = 60.0; // Basisgröße für den ersten Fisch
    const sizeIncrement = 10.0; // Erhöhung pro Typ
    const maxTypes = 5; // Maximale Anzahl an Fisch-Typen
    return baseSize + (index.clamp(0, maxTypes - 1) * sizeIncrement);
  }

  void _updateAnimations(double fishSize, double screenWidth) {
    if (_globalController != null) {
      final maxHorizontalMovement = screenWidth - fishSize - 200; // Berücksichtige fishSize bei der maximalen Bewegung
      final threshold = screenWidth * 0.8; // 80% der Bildschirmbreite

      // Überprüfe, ob der Fisch nahe an 80% der Bildschirmbreite ist
      if (_currentLeft > threshold && _movingRight) {
        _movingRight = false; // Wechsel die Richtung nach links
      } else if (_currentLeft < fishSize && !_movingRight) {
        _movingRight = true; // Wechsel die Richtung nach rechts
      }

      // Bestimme die horizontale Bewegung basierend auf der Richtung
      final horizontalEnd = _movingRight
          ? _random.nextDouble() * maxHorizontalMovement // Bewege nach rechts
          : -_random.nextDouble() * maxHorizontalMovement; // Bewege nach links
      final verticalEnd = _random.nextDouble() * 20 - 10; // Zufälliger vertikaler Abstand (-10 bis 10)

      _positionAnimation = Tween<double>(begin: 0, end: horizontalEnd).animate(
        CurvedAnimation(parent: _globalController!, curve: Curves.easeInOut),
      );
      _verticalAnimation = Tween<double>(begin: 0, end: verticalEnd).animate(
        CurvedAnimation(parent: _globalController!, curve: Curves.easeInOutSine),
      );
      // Rotation basierend auf der Bewegungsrichtung
      final rotationDirection = horizontalEnd > 0 ? 0.5 : -0.5; // Neigt sich in die Schwimmrichtung
      _rotationAnimation = Tween<double>(begin: 0, end: rotationDirection).animate(
        CurvedAnimation(parent: _globalController!, curve: Curves.easeInOutBack),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized && mounted) {
        try {
          _globalController = AnimationController(
            duration: const Duration(seconds: 3), // Langsame Bewegung (3 Sekunden)
            vsync: this,
          );
          _isInitialized = true;

          // Initiale Position berechnen
          final screenWidth = MediaQuery.of(context).size.width;
          _currentLeft = widget.fish.price * 100; // Basisposition basierend auf Index
          _currentTop = MediaQuery.of(context).size.height * 0.3 + (widget.fish.price % 2 == 0 ? 50 : -50);

          final fishSize = _getFishSize(widget.fish.price);
          _updateAnimations(fishSize, screenWidth); // Initiale Animationen setzen
          setState(() {});
          print('AnimationController initialized for fish type ${widget.fish.type}');
          _startTimer(); // Starte den Timer nach der Initialisierung
        } catch (e) {
          print('Error initializing animation for fish type ${widget.fish.type}: $e');
        }
      }
    });
  }

  // Methode zum Starten des Timers
  void _startTimer() {
    _timer?.cancel(); // Beende den bestehenden Timer, falls vorhanden
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_globalController != null && mounted) {
        if (!_globalController!.isAnimating) {
          final fishSize = _getFishSize(widget.fish.size as int);
          final screenWidth = MediaQuery.of(context).size.width;
          _updateAnimations(fishSize, screenWidth); // Neue zufällige Pfade bei jedem Zyklus
          _globalController!.forward(from: 0.0); // Starte von Anfang, aber behalte aktuelle Position
          print('Animation started for fish type ${widget.fish.type} at ${DateTime.now()}');
        }
      }
    });

    // Nach jedem Zyklus die aktuelle Position aktualisieren (wenn die Animation abgeschlossen ist)
    _globalController!.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _currentLeft += _positionAnimation?.value ?? 0; // Aktualisiere die aktuelle Position
          _currentTop += _verticalAnimation?.value ?? 0;
          print('Fish type ${widget.fish.type} ended at left: $_currentLeft, top: $_currentTop');
        });
      }
    });
  }

  @override
  void dispose() {
    _globalController?.dispose();
    _timer?.cancel(); // Timer beim Verwerfen des Widgets beenden
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_globalController == null) {
      return const SizedBox.shrink(); // Fallback während der Initialisierung
    }

    final fishSize = _getFishSize(widget.fish.size as int);
    return AnimatedBuilder(
      animation: _globalController!,
      builder: (context, child) {
        // Bewegung über den Bildschirm: Der Fisch bewegt sich zufällig
        final horizontalMovement = (_positionAnimation?.value ?? 0);
        final verticalMovement = (_verticalAnimation?.value ?? 0);

        // Position basierend auf der aktuellen Position
        final currentLeft = _currentLeft + horizontalMovement;
        final currentTop = _currentTop + verticalMovement;

        // Grenzen prüfen, um den Fisch im Bildschirm zu halten
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final boundedLeft = currentLeft.clamp(0, screenWidth - fishSize).toDouble();
        final boundedTop = currentTop.clamp(0, screenHeight - fishSize).toDouble();

        return Stack(
          children: [
            Positioned(
              left: boundedLeft,
              top: boundedTop,
              child: Transform.rotate(
                angle: _rotationAnimation?.value ?? 0,
                child: SizedBox(
                  width: fishSize,
                  height: fishSize,
                  child: Lottie.asset(
                    widget.fish.assetPath,
                    width: fishSize,
                    height: fishSize,
                    fit: BoxFit.contain,
                    controller: _globalController, // Direkt den AnimationController an Lottie binden
                    frameRate: FrameRate(15), // Reduziert auf 15 FPS
                    options: LottieOptions(
                      enableMergePaths: true,
                      enableApplyingOpacityToLayers: true,
                    ),
                    onLoaded: (composition) {
                      print('Lottie animation loaded for fish type ${widget.fish.type}: $composition');
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}