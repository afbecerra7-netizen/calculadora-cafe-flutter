import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        gradient: const LinearGradient(
          colors: [Color(0xE8FFFFFF), Color(0xCCFFF2E1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7A593A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  height: 0.92,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBD6A15),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit.toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF815B36),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
