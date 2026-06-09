import 'package:flutter/material.dart';

/// Mini-grafico a linea senza assi né etichette: mostra a colpo d'occhio
/// l'andamento di una serie di valori. Disegnato con un CustomPainter (leggero).
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.width = 64,
    this.height = 28,
    this.strokeWidth = 1.6,
  });

  final List<double> values;
  final Color color;
  final double width;
  final double height;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(width: width, height: height);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    var min = values.first;
    var max = values.first;
    for (final v in values) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    final range = (max - min).abs();
    final pad = strokeWidth; // margine per non tagliare la linea ai bordi

    double x(int i) => pad + (size.width - 2 * pad) * (i / (values.length - 1));
    double y(double v) {
      if (range == 0) return size.height / 2;
      final t = (v - min) / range; // 0..1
      return size.height - pad - (size.height - 2 * pad) * t;
    }

    final path = Path()..moveTo(x(0), y(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }

    // Riempimento tenue sotto la linea.
    final fill = Path.from(path)
      ..lineTo(x(values.length - 1), size.height)
      ..lineTo(x(0), size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: 0.10),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}
