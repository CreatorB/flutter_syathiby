import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syathiby/utils/extension/color.dart';

typedef AsyncTapCallback = FutureOr<void> Function();

/// Elegant 3D Sphere Icon Widget
///
/// A reusable widget that creates a beautiful 3D spherical icon
/// with gradient background and multiple shadow layers for realistic depth.
///
/// Features:
/// - Circular 3D sphere shape (not square)
/// - Multi-layer shadows for realistic depth
/// - Radial gradient for spherical appearance
/// - White icons for better contrast
/// - Customizable size and colors
/// - Border highlight for edge definition
class Elegant3DIcon extends StatelessWidget {
  /// The icon to display
  final IconData iconData;

  /// Size of the container (width and height)
  final double size;

  /// Size of the icon
  final double iconSize;

  /// Primary color for the sphere body
  /// If null, uses theme's primary color
  final Color? primaryColor;

  /// Intensity of the 3D effect (0.0 to 1.0)
  /// Higher values create deeper shadows
  final double depth;

  const Elegant3DIcon({
    super.key,
    required this.iconData,
    this.size = 58,
    this.iconSize = 24,
    this.primaryColor,
    this.depth = 0.72,
  }) : assert(
            depth >= 0.0 && depth <= 1.0, 'Depth must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor = primaryColor ?? context.colorPrimary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Radial gradient for spherical appearance
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 1.2,
          colors: [
            effectivePrimaryColor.withOpacity(0.9),
            effectivePrimaryColor,
            effectivePrimaryColor.withOpacity(0.85),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        shape: BoxShape.circle,
        // Multiple shadow layers for 3D depth perception
        boxShadow: [
          // Top-left highlight (simulated light source for sphere)
          BoxShadow(
            color: Colors.white.withOpacity(0.4 * depth),
            offset: Offset(-2 * depth, -2 * depth),
            blurRadius: 6 * depth,
            spreadRadius: 0.5 * depth,
          ),
          // Bottom-right main shadow
          BoxShadow(
            color: effectivePrimaryColor.withOpacity(0.5 * depth),
            offset: Offset(3.5 * depth, 3.5 * depth),
            blurRadius: 10 * depth,
            spreadRadius: 0,
          ),
          // Additional depth shadow (deeper layer)
          BoxShadow(
            color: Colors.black.withOpacity(0.25 * depth),
            offset: Offset(7 * depth, 7 * depth),
            blurRadius: 16 * depth,
            spreadRadius: -1.5 * depth,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          iconData,
          color: Colors.white,
          size: iconSize,
          // Icon shadow for extra depth
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Elegant 3D Sphere Icon Button
///
/// An interactive version of Elegant3DIcon with tap callback and bounce animation
class Elegant3DIconButton extends StatefulWidget {
  /// The icon to display
  final IconData iconData;

  /// Callback when the button is tapped
  final AsyncTapCallback onTap;

  /// Size of the container (width and height)
  final double size;

  /// Size of the icon
  final double iconSize;

  /// Primary color for the sphere body
  final Color? primaryColor;

  /// Intensity of the 3D effect (0.0 to 1.0)
  final double depth;

  /// Show loading spinner and disable interactions
  final bool isLoading;

  const Elegant3DIconButton({
    super.key,
    required this.iconData,
    required this.onTap,
    this.size = 58,
    this.iconSize = 24,
    this.primaryColor,
    this.depth = 0.72,
    this.isLoading = false,
  });

  @override
  State<Elegant3DIconButton> createState() => _Elegant3DIconButtonState();
}

class _Elegant3DIconButtonState extends State<Elegant3DIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateYAnimation;
  bool _isTapLocked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Visible bounce: press down -> overshoot -> settle back to normal.
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // Small vertical movement to make tap feedback obvious.
    _translateYAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 2.5)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.5, end: -2.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -2.0, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isTapLocked || widget.isLoading) return;
    _isTapLocked = true;

    // Trigger bounce animation
    unawaited(_animationController.forward(from: 0.0));
    await widget.onTap();

    if (mounted) {
      _isTapLocked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateYAnimation.value),
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: widget.isLoading ? 0.72 : 1,
              child: Elegant3DIcon(
                iconData: widget.iconData,
                size: widget.size,
                iconSize: widget.iconSize,
                primaryColor: widget.primaryColor,
                depth: widget.depth,
              ),
            ),
            if (widget.isLoading)
              SizedBox(
                width: widget.iconSize,
                height: widget.iconSize,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
