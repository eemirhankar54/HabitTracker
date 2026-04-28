// lib/widgets/progress_ring.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;

  const ProgressRing({super.key, required this.progress,
    this.size = 72, this.strokeWidth = 6});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _RingPainter(progress: progress, strokeWidth: strokeWidth),
        ),
        Text('${(progress * 100).round()}%',
          style: const TextStyle(color: AppColors.textPrimary,
            fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double progress, strokeWidth;
  _RingPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - strokeWidth) / 2;

    canvas.drawCircle(c, r, Paint()
      ..color = AppColors.surfaceVar
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2, 2 * pi * progress, false,
        Paint()
          ..shader = AppColors.primaryGradient
              .createShader(Rect.fromCircle(center: c, radius: r))
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
