import 'package:flutter/material.dart';

class GradientIconPainter extends CustomPainter {
  final IconData icon;
  final double size;
  final Gradient gradient;

  GradientIconPainter({
    required this.icon,
    required this.size,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, this.size, this.size);
    final Paint paint = Paint()..shader = gradient.createShader(rect);

    final TextSpan span = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: this.size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        foreground: paint,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: this.size, maxWidth: this.size);
    textPainter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}