import 'dart:ui';

import 'package:flutter/material.dart';

class QuickSummary extends StatelessWidget {
  const QuickSummary({
    super.key,
    required this.coffee,
    required this.water,
    required this.unit,
    required this.onCopy,
    required this.onViewDetail,
  });

  final String coffee;
  final String water;
  final String unit;
  final VoidCallback onCopy;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
            gradient: const LinearGradient(
              colors: [Color(0xEEFFFFFF), Color(0xE6FFEEDA)],
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                offset: Offset(0, 8),
                color: Color(0x265C3816),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Cafe $coffee g\nAgua $water ${unit.toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF4D361F),
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.tonal(
                onPressed: onViewDetail,
                child: const Text('Detalle'),
              ),
              const SizedBox(width: 6),
              FilledButton(
                onPressed: onCopy,
                child: const Text('Copiar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
