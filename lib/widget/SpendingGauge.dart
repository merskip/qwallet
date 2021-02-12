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
      painter: _GaugePainter(
        segments: [
          _GaugeSegment(Colors.red, 0.67, 0.33),
          _GaugeSegment(Colors.orange, 0.5, 0.17),
          _GaugeSegment(Colors.green, 0.0, 0.5),
        ],
        markerPosition: 0.6,
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final List<_GaugeSegment> segments;
  final double markerPosition;

  final double segmentWidth = 7.5;
  final double markerRadius = 6;

  _GaugePainter({this.segments, this.markerPosition});

  @override
  void paint(Canvas canvas, Size size) {
    _paintSegments(canvas, size);
    _paintMarker(canvas, size);
  }

  void _paintSegments(Canvas canvas, Size size) {
    for (final segment in segments) {
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = segmentWidth;

      final halfWidth = segmentWidth / 2;
      final rect = Rect.fromLTRB(halfWidth, halfWidth, size.width - halfWidth,
          size.height - halfWidth);
      final arcStart = pi / 2 - segment.sweep * pi - segment.start * pi;
      final arcSweep = segment.sweep * pi;
      canvas.drawArc(rect, arcStart, arcSweep, false, paint);
    }
  }

  void _paintMarker(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    final markerSegment = segments.lastWhere((s) =>
        markerPosition >= s.start && markerPosition <= s.start + s.sweep);

    canvas.rotate(pi / 2 - markerPosition * pi);
    canvas.translate(size.width / 2, 0);

    final circlePaint = Paint()
      ..color = markerSegment.color.shade100
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-segmentWidth / 2, 0), markerRadius, circlePaint);

    final borderPaint = Paint()
      ..color = markerSegment.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(-segmentWidth / 2, 0), markerRadius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) {
    return false;
  }
}

class _GaugeSegment {
  final MaterialColor color;
  final double start;
  final double sweep;

  _GaugeSegment(this.color, this.start, this.sweep);
}
