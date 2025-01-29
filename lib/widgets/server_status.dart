import 'dart:io';
import 'package:flutter/material.dart';

class ServerStatus extends StatelessWidget {
  final String status;

  const ServerStatus({required this.status, super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case "running":
        return Colors.green;
      case "stopped":
        return Colors.red;
      case "restarting":
        return Colors.orange;
      case "error":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "Status: $status",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}