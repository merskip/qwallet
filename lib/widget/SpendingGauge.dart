import 'dart:math';

import 'package:flutter/material.dart';

class SpendingGauge extends StatefulWidget {
  @override
  _SpendingGaugeState createState() => _SpendingGaugeState();
}

class _SpendingGaugeState extends State<SpendingGauge> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(100, 100),
      painter: _GaugePainter([
        _GaugeSegment(Colors.red, 0.67, 0.33),
        _GaugeSegment(Colors.orange, 0.33, 0.34),
        _GaugeSegment(Colors.green, 0.0, 0.33),
      ]),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final List<_GaugeSegment> segments;

  final double width = 10;

  _GaugePainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    for (final segment in segments) {
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width;

      final halfWidth = width / 2;
      final rect = Rect.fromLTRB(halfWidth, halfWidth, size.width - halfWidth,
          size.height - halfWidth);
      final arcStart = pi / 2 - segment.sweep * pi - segment.start * pi;
      final arcSweep = segment.sweep * pi;
      canvas.drawArc(rect, arcStart, arcSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) {
    return false;
  }
}

class _GaugeSegment {
  final Color color;
  final double start;
  final double sweep;

  _GaugeSegment(this.color, this.start, this.sweep);
}
