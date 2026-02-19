import 'package:flutter/material.dart';

class BackgroundOrbs extends StatelessWidget {
  const BackgroundOrbs({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(
          right: -80,
          top: -80,
          child: _Orb(size: 260, color: Color(0x55F1B97A)),
        ),
        Positioned(
          left: -70,
          bottom: -100,
          child: _Orb(size: 230, color: Color(0x3AD48D52)),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
