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
      size: Size(128, 128),
      painter: _GaugePainter(
        segments: [
          _GaugeSegment(Colors.red, 0.67, 0.33),
          _GaugeSegment(Colors.orange, 0.5, 0.17),
          _GaugeSegment(Colors.green, 0.0, 0.5),
        ],
        labels: [
          _GaugeLabel(
              0.67,
              "100 zł",
              Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.red)),
          _GaugeLabel(
              0.5,
              "80 zł",
              Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.orange)),
        ],
        markerPosition: 0.6,
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final List<_GaugeSegment> segments;
  final List<_GaugeLabel> labels;
  final double markerPosition;

  final double segmentWidth = 7.5;
  final double markerRadius = 6;

  _GaugePainter({this.segments, this.labels, this.markerPosition});

  @override
  void paint(Canvas canvas, Size size) {
    _paintSegments(canvas, size);
    _paintLabels(canvas, size);
    _paintMarker(canvas, size);
  }

  void _paintSegments(Canvas canvas, Size size) {
    for (final segment in segments) {
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = segmentWidth;

      final rect = Rect.fromLTWH(
        -size.width / 2 + segmentWidth,
        segmentWidth / 2,
        size.width - segmentWidth,
        size.height - segmentWidth,
      );
      final arcStart = pi / 2 - segment.sweep * pi - segment.start * pi;
      final arcSweep = segment.sweep * pi;
      canvas.drawArc(rect, arcStart, arcSweep, false, paint);
    }
  }

  void _paintLabels(Canvas canvas, Size size) {
    for (final label in labels) {
      _drawText(canvas, size, label.position, label.text, label.style);
    }
  }

  void _paintMarker(Canvas canvas, Size size) {
    canvas.save();
    _translate(canvas, size, markerPosition);

    final markerSegment = segments.lastWhere((s) =>
        markerPosition >= s.start && markerPosition <= s.start + s.sweep);
    final circlePaint = Paint()
      ..color = markerSegment.color.shade100
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, markerRadius, circlePaint);

    final borderPaint = Paint()
      ..color = markerSegment.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, markerRadius, borderPaint);

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    Size size,
    double position,
    String text,
    TextStyle style,
  ) {
    canvas.save();
    _translate(canvas, size, position);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(segmentWidth, 2 * -textPainter.height / 3);
    textPainter.paint(canvas, offset);

    canvas.restore();
  }

  void _translate(Canvas canvas, Size size, double position) {
    canvas.translate(segmentWidth / 2, size.height / 2);
    canvas.rotate(pi / 2 - position * pi);
    canvas.translate(size.width / 2 - segmentWidth / 2, 0);
    canvas.rotate(position * pi - pi / 2);
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

  double get end => start + sweep;

  _GaugeSegment(this.color, this.start, this.sweep);
}

class _GaugeLabel {
  final double position;
  final String text;
  final TextStyle style;

  _GaugeLabel(this.position, this.text, this.style);
}
