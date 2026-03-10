import 'package:flutter/material.dart';
import 'package:syathiby/utils/extension/color.dart';

/// Elegant 3D Card Widget
/// 
/// A beautiful 3D elevated card with gradient background
/// and multiple shadow layers for realistic depth perception.
/// 
/// Features:
/// - Multi-layer shadows for 3D effect
/// - Optional gradient background
/// - Customizable border and shadow
/// - Smooth rounded corners
/// - Adjustable depth intensity
class Elegant3DCard extends StatelessWidget {
  /// The widget below this widget in the tree
  final Widget child;
  
  /// Width of the card
  final double? width;
  
  /// Height of the card
  final double? height;
  
  /// Internal padding
  final EdgeInsetsGeometry? padding;
  
  /// Border radius
  final double borderRadius;
  
  /// Use gradient background
  final bool useGradient;
  
  /// Background color (used if gradient is disabled)
  final Color? backgroundColor;
  
  /// Gradient colors (if gradient is enabled)
  final List<Color>? gradientColors;
  
  /// Shadow color (defaults to primary color)
  final Color? shadowColor;
  
  /// Intensity of the 3D effect (0.0 to 1.0)
  final double depth;
  
  /// Border width
  final double? borderWidth;
  
  /// Border color
  final Color? borderColor;

  const Elegant3DCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 20,
    this.useGradient = true,
    this.backgroundColor,
    this.gradientColors,
    this.shadowColor,
    this.depth = 1.0,
    this.borderWidth,
    this.borderColor,
  }) : assert(depth >= 0.0 && depth <= 1.0, 'Depth must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    final effectiveShadowColor = shadowColor ?? context.colorPrimary;
    final effectiveBorderColor = borderColor ?? effectiveShadowColor.withOpacity(0.3);
    
    final BoxDecoration decoration = BoxDecoration(
      // Background: gradient or solid color
      gradient: useGradient
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors ?? [
                backgroundColor ?? context.colorSurface,
                (backgroundColor ?? context.colorPrimaryContainer).withOpacity(0.3),
              ],
            )
          : null,
      color: useGradient ? null : (backgroundColor ?? context.colorSurface),
      borderRadius: BorderRadius.circular(borderRadius),
      // Multi-layer shadows for 3D effect
      boxShadow: [
        // Top-left highlight (light source)
        BoxShadow(
          color: Colors.white.withOpacity(0.5 * depth),
          offset: Offset(-2 * depth, -2 * depth),
          blurRadius: 6 * depth,
          spreadRadius: 0,
        ),
        // Bottom-right main shadow
        BoxShadow(
          color: effectiveShadowColor.withOpacity(0.25 * depth),
          offset: Offset(4 * depth, 4 * depth),
          blurRadius: 12 * depth,
          spreadRadius: 0,
        ),
        // Additional depth shadow
        BoxShadow(
          color: effectiveShadowColor.withOpacity(0.15 * depth),
          offset: Offset(6 * depth, 6 * depth),
          blurRadius: 16 * depth,
          spreadRadius: 0,
        ),
      ],
      // Border for definition
      border: Border.all(
        color: effectiveBorderColor,
        width: borderWidth ?? 1.5,
      ),
    );

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}

/// Elegant 3D Card Button
/// 
/// An interactive version of Elegant3DCard with tap callback
class Elegant3DCardButton extends StatelessWidget {
  /// The widget below this widget in the tree
  final Widget child;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;
  
  /// Width of the card
  final double? width;
  
  /// Height of the card
  final double? height;
  
  /// Internal padding
  final EdgeInsetsGeometry? padding;
  
  /// Border radius
  final double borderRadius;
  
  /// Use gradient background
  final bool useGradient;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Gradient colors
  final List<Color>? gradientColors;
  
  /// Shadow color
  final Color? shadowColor;
  
  /// Intensity of the 3D effect (0.0 to 1.0)
  final double depth;
  
  /// Border width
  final double? borderWidth;
  
  /// Border color
  final Color? borderColor;

  const Elegant3DCardButton({
    super.key,
    required this.child,
    required this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 20,
    this.useGradient = true,
    this.backgroundColor,
    this.gradientColors,
    this.shadowColor,
    this.depth = 1.0,
    this.borderWidth,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Elegant3DCard(
        width: width,
        height: height,
        padding: padding,
        borderRadius: borderRadius,
        useGradient: useGradient,
        backgroundColor: backgroundColor,
        gradientColors: gradientColors,
        shadowColor: shadowColor,
        depth: depth,
        borderWidth: borderWidth,
        borderColor: borderColor,
        child: child,
      ),
    );
  }
}
