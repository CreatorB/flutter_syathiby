import 'package:flutter/material.dart';
import 'package:syathiby/utils/extension/color.dart';

/// Elegant 3D Button with gradient and shadow effects
///
/// A button widget that creates a beautiful 3D effect with gradient background
/// and multiple shadow layers for realistic depth perception.
///
/// Features:
/// - Gradient background from light to dark
/// - Multi-layer shadows for 3D depth
/// - Customizable colors and sizes
/// - Smooth tap animation with scale transition
/// - Optional icon support
class Elegant3DButton extends StatefulWidget {
  /// Button label text
  final String label;

  /// Callback when button is tapped
  final VoidCallback onPressed;

  /// Optional icon before the text
  final IconData? icon;

  /// Background color (primary)
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Button width (full width if null)
  final double? width;

  /// Button height
  final double height;

  /// Intensity of 3D effect
  final double depth;

  /// Shows loading state and disables tap interaction
  final bool isLoading;

  /// Label shown while loading
  final String loadingLabel;

  const Elegant3DButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.width,
    this.height = 46,
    this.depth = 0.68,
    this.isLoading = false,
    this.loadingLabel = 'Memproses...',
  });

  @override
  State<Elegant3DButton> createState() => _Elegant3DButtonState();
}

class _Elegant3DButtonState extends State<Elegant3DButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _loadingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingLiftAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 430),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 760),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.9)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 32,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.04)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 38,
      ),
    ]).animate(_animationController);

    _loadingLiftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _loadingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant Elegant3DButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading == oldWidget.isLoading) return;
    if (widget.isLoading) {
      _loadingController.repeat(reverse: true);
    } else {
      _loadingController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isLoading) return;
    _animationController.forward(from: 0.0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        widget.backgroundColor ?? context.colorPrimary;
    final effectiveTextColor = widget.textColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _loadingLiftAnimation,
      builder: (context, child) {
        final loadingOffset =
            widget.isLoading ? -1.6 * _loadingLiftAnimation.value : 0.0;
        return Transform.translate(
            offset: Offset(0, loadingOffset), child: child);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              // Gradient background
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  effectiveBackgroundColor.withOpacity(0.95),
                  effectiveBackgroundColor,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              // Multiple shadow layers for 3D depth
              boxShadow: [
                // Top-left highlight (light source)
                BoxShadow(
                  color: Colors.white.withOpacity(0.3 * widget.depth),
                  offset: Offset(-1.5 * widget.depth, -1.5 * widget.depth),
                  blurRadius: 5 * widget.depth,
                  spreadRadius: 0.5 * widget.depth,
                ),
                // Bottom-right main shadow
                BoxShadow(
                  color:
                      effectiveBackgroundColor.withOpacity(0.5 * widget.depth),
                  offset: Offset(4 * widget.depth, 4 * widget.depth),
                  blurRadius: 10 * widget.depth,
                  spreadRadius: 0,
                ),
                // Additional depth shadow (deeper layer)
                BoxShadow(
                  color: Colors.black.withOpacity(0.2 * widget.depth),
                  offset: Offset(8 * widget.depth, 8 * widget.depth),
                  blurRadius: 16 * widget.depth,
                  spreadRadius: -2 * widget.depth,
                ),
              ],
              // Subtle border for edge definition
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: effectiveTextColor,
                      size: 18,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: widget.isLoading
                        ? Row(
                            key: const ValueKey('loading'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      effectiveTextColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.loadingLabel,
                                style: TextStyle(
                                  color: effectiveTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            widget.label,
                            key: const ValueKey('label'),
                            style: TextStyle(
                              color: effectiveTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
