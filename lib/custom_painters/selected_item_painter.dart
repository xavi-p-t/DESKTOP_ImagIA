// lib/custom_painters/selected_item_painter.dart
import 'package:flutter/material.dart';

class SelectedItemPainter extends CustomPainter {
  final bool isSelected;
  final Color selectedColor;

  SelectedItemPainter({required this.isSelected, this.selectedColor = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    if (isSelected) {
      final paint = Paint()
        ..color = selectedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(12.0));

      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
