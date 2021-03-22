import 'dart:math';

import 'package:flutter/material.dart';

import '../Money.dart';
import '../utils/IterableFinding.dart';

class SpendingGauge extends StatefulWidget {
  final Money midLow;
  final Money midHigh;
  final Money max;
  final Money current;

  const SpendingGauge({
    Key? key,
    required this.midLow,
    required this.midHigh,
    required this.max,
    required this.current,
  }) : super(key: key);

  @override
  _SpendingGaugeState createState() => _SpendingGaugeState();
}

class _SpendingGaugeState extends State<SpendingGauge> {
  @override
  Widget build(BuildContext context) {
    if (widget.max.amount == 0) {
      return buildEmptyGauge(context);
    }

    final normalizedMidLow = widget.midLow.amount! / widget.max.amount!;
    final normalizedMidHigh = widget.midHigh.amount! / widget.max.amount!;
    final normalizedCurrent = widget.current.amount! / widget.max.amount!;

    return CustomPaint(
      painter: _GaugePainter(
        segments: [
          _GaugeSegment(Colors.red, normalizedMidHigh, 1.0),
          _GaugeSegment(Colors.orange, normalizedMidLow, normalizedMidHigh),
          _GaugeSegment(Colors.green, 0.0, normalizedMidLow),
        ],
        labels: [
          _GaugeLabel(
              normalizedMidHigh,
              widget.midHigh.formatted,
              Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.red)),
          _GaugeLabel(
              normalizedMidLow,
              widget.midLow.formatted,
              Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.orange)),
        ],
        markerPosition: normalizedCurrent,
      ),
    );
  }

  Widget buildEmptyGauge(BuildContext context) {
    return CustomPaint(
      painter: _GaugePainter(
        segments: [
          _GaugeSegment(Colors.green, 0.0, 1.0),
        ],
        labels: [],
        markerPosition: null,
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final List<_GaugeSegment> segments;
  final List<_GaugeLabel> labels;
  final double? markerPosition;

  final double segmentWidth = 7.5;
  final double markerRadius = 6;

  _GaugePainter({
    required this.segments,
    required this.labels,
    this.markerPosition,
  });

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
    if (this.markerPosition == null) return;
    final markerPosition =
        max(segments.last.start, min(segments.first.end, this.markerPosition!));
    canvas.save();

    final markerSegment = segments.findLastOrNull(
      (s) => markerPosition >= s.start && markerPosition <= s.end,
    );
    if (markerSegment == null) return;
    _translate(canvas, size, markerPosition);

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
  final double end;

  double get sweep => end - start;

  _GaugeSegment(this.color, this.start, this.end);
}

class _GaugeLabel {
  final double position;
  final String text;
  final TextStyle style;

  _GaugeLabel(this.position, this.text, this.style);
}
