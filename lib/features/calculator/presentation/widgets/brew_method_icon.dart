import 'package:flutter/material.dart';

import '../../domain/coffee_calculator.dart';

class BrewMethodIcon extends StatelessWidget {
  const BrewMethodIcon({
    super.key,
    required this.method,
    required this.color,
    this.size = 24,
  });

  final BrewMethod method;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (method) {
      case BrewMethod.aeropress:
        return _AeroPressIcon(color: color, size: size);
      case BrewMethod.chemex:
        return _ChemexIcon(color: color, size: size);
      case BrewMethod.v60:
        return _V60Icon(color: color, size: size);
      case BrewMethod.frenchpress:
        return _FrenchPressIcon(color: color, size: size);
      case BrewMethod.coldbrew:
        return Icon(Icons.ac_unit_outlined, color: color, size: size);
      case BrewMethod.mokaItaliana:
        return _MokaPotIcon(color: color, size: size);
    }
  }
}

class _AeroPressIcon extends StatelessWidget {
  const _AeroPressIcon({required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AeroPressPainter(color),
      ),
    );
  }
}

class _AeroPressPainter extends CustomPainter {
  const _AeroPressPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.1;
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final handle = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.08,
        size.width * 0.4,
        size.height * 0.07,
      ),
      Radius.circular(size.shortestSide * 0.05),
    );
    canvas.drawRRect(handle, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.5, size.height * 0.24),
      linePaint,
    );

    final chamber = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.24,
        size.width * 0.3,
        size.height * 0.45,
      ),
      Radius.circular(size.shortestSide * 0.08),
    );
    canvas.drawRRect(chamber, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.33, size.height * 0.71),
      Offset(size.width * 0.67, size.height * 0.71),
      linePaint,
    );

    final cup = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.29,
        size.height * 0.72,
        size.width * 0.42,
        size.height * 0.2,
      ),
      Radius.circular(size.shortestSide * 0.07),
    );
    canvas.drawRRect(cup, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.93),
      Offset(size.width * 0.75, size.height * 0.93),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AeroPressPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ChemexIcon extends StatelessWidget {
  const _ChemexIcon({required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ChemexPainter(color),
      ),
    );
  }
}

class _ChemexPainter extends CustomPainter {
  const _ChemexPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.1;
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final top = Path()
      ..moveTo(size.width * 0.26, size.height * 0.2)
      ..lineTo(size.width * 0.74, size.height * 0.2)
      ..lineTo(size.width * 0.62, size.height * 0.38)
      ..lineTo(size.width * 0.38, size.height * 0.38)
      ..close();
    canvas.drawPath(top, linePaint);

    final collar = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.31,
        size.height * 0.41,
        size.width * 0.38,
        size.height * 0.09,
      ),
      Radius.circular(size.shortestSide * 0.05),
    );
    canvas.drawRRect(collar, linePaint);

    final bottom = Path()
      ..moveTo(size.width * 0.38, size.height * 0.5)
      ..cubicTo(
        size.width * 0.27,
        size.height * 0.62,
        size.width * 0.26,
        size.height * 0.79,
        size.width * 0.38,
        size.height * 0.86,
      )
      ..lineTo(size.width * 0.62, size.height * 0.86)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.79,
        size.width * 0.73,
        size.height * 0.62,
        size.width * 0.62,
        size.height * 0.5,
      );
    canvas.drawPath(bottom, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ChemexPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _V60Icon extends StatelessWidget {
  const _V60Icon({required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _V60Painter(color),
      ),
    );
  }
}

class _V60Painter extends CustomPainter {
  const _V60Painter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.1;
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dripper = Path()
      ..moveTo(size.width * 0.22, size.height * 0.28)
      ..lineTo(size.width * 0.78, size.height * 0.28)
      ..lineTo(size.width * 0.62, size.height * 0.66)
      ..lineTo(size.width * 0.38, size.height * 0.66)
      ..close();
    canvas.drawPath(dripper, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.66),
      Offset(size.width * 0.5, size.height * 0.75),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.75),
      Offset(size.width * 0.62, size.height * 0.75),
      linePaint,
    );

    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.29,
        size.height * 0.76,
        size.width * 0.42,
        size.height * 0.14,
      ),
      Radius.circular(size.shortestSide * 0.06),
    );
    canvas.drawRRect(base, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.93),
      Offset(size.width * 0.78, size.height * 0.93),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.36),
      Offset(size.width * 0.43, size.height * 0.6),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.46, size.height * 0.34),
      Offset(size.width * 0.53, size.height * 0.61),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.36),
      Offset(size.width * 0.63, size.height * 0.56),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _V60Painter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _FrenchPressIcon extends StatelessWidget {
  const _FrenchPressIcon({required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FrenchPressPainter(color),
      ),
    );
  }
}

class _FrenchPressPainter extends CustomPainter {
  const _FrenchPressPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.1;
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.26,
        size.width * 0.4,
        size.height * 0.54,
      ),
      Radius.circular(size.shortestSide * 0.11),
    );
    canvas.drawRRect(body, linePaint);

    final lid = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.16,
        size.width * 0.5,
        size.height * 0.11,
      ),
      Radius.circular(size.shortestSide * 0.08),
    );
    canvas.drawRRect(lid, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.23, size.height * 0.28),
      Offset(size.width * 0.77, size.height * 0.28),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.16),
      Offset(size.width * 0.5, size.height * 0.55),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.55),
      Offset(size.width * 0.62, size.height * 0.55),
      linePaint,
    );

    final knobPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.11),
      size.shortestSide * 0.035,
      knobPaint,
    );

    final handle = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.72,
        size.height * 0.34,
        size.width * 0.12,
        size.height * 0.35,
      ),
      Radius.circular(size.shortestSide * 0.06),
    );
    canvas.drawRRect(handle, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.9),
      Offset(size.width * 0.82, size.height * 0.9),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FrenchPressPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _MokaPotIcon extends StatelessWidget {
  const _MokaPotIcon({required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MokaPotPainter(color),
      ),
    );
  }
}

class _MokaPotPainter extends CustomPainter {
  const _MokaPotPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.12;
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final lid = Path()
      ..moveTo(size.width * 0.18, size.height * 0.35)
      ..lineTo(size.width * 0.5, size.height * 0.16)
      ..lineTo(size.width * 0.82, size.height * 0.35);
    canvas.drawPath(lid, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.37),
      Offset(size.width * 0.84, size.height * 0.37),
      linePaint,
    );

    final upperBody = Path()
      ..moveTo(size.width * 0.23, size.height * 0.37)
      ..lineTo(size.width * 0.34, size.height * 0.56)
      ..lineTo(size.width * 0.66, size.height * 0.56)
      ..lineTo(size.width * 0.77, size.height * 0.37);
    canvas.drawPath(upperBody, linePaint);

    canvas.drawLine(
      Offset(size.width * 0.31, size.height * 0.62),
      Offset(size.width * 0.69, size.height * 0.62),
      linePaint,
    );

    final lowerBody = Path()
      ..moveTo(size.width * 0.31, size.height * 0.62)
      ..lineTo(size.width * 0.25, size.height * 0.86)
      ..lineTo(size.width * 0.75, size.height * 0.86)
      ..lineTo(size.width * 0.69, size.height * 0.62);
    canvas.drawPath(lowerBody, linePaint);

    final handle = Path()
      ..moveTo(size.width * 0.82, size.height * 0.39)
      ..quadraticBezierTo(
        size.width * 0.97,
        size.height * 0.46,
        size.width * 0.86,
        size.height * 0.58,
      );
    canvas.drawPath(handle, linePaint);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.11),
      size.shortestSide * 0.045,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MokaPotPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
