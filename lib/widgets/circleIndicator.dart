
import 'package:flutter/material.dart';


class CircleIndicator extends StatelessWidget {
  final bool isActive;

  const CircleIndicator({required this.isActive, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}