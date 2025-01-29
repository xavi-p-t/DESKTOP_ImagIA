import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Widgets Example')),
        body: const WidgetsExample(),
      ),
    );
  }
}

class WidgetsExample extends StatelessWidget {
  const WidgetsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleIndicator(isActive: true),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          const ServerStatusWidget(status: "running"),
        ],
      ),
    );
  }
}


// 2. Widget que muestra un círculo verde o rojo según un booleano
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


// 4. Widget para configurar redirecciones del puerto 80 a otro puerto


// 5. Widget que muestra el estado de un servidor
class ServerStatusWidget extends StatelessWidget {
  final String status;

  const ServerStatusWidget({required this.status, super.key});

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
