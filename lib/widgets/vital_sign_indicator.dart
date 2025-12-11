import 'package:flutter/material.dart';

class VitalSignIndicator extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final IconData icon;

  const VitalSignIndicator({
    super.key,
    required this.label,
    required this.value,
    this.max = 100,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Ring
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: 1.0,
                  color: color.withValues(alpha: 0.1),
                  strokeWidth: 4,
                ),
              ),
              // Value Ring
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: value / max,
                  color: color,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Icon inside
              Icon(
                icon,
                color: color,
                size: 24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value/$max',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
