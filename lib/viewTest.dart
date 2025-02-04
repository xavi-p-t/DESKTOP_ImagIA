import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../connection.dart';

class ViewTest extends StatefulWidget {
  final ServerConnectionManager connectionManager;

  const ViewTest({super.key, required this.connectionManager});

  @override
  _ViewTestState createState() => _ViewTestState();
}

class _ViewTestState extends State<ViewTest> {
  @override
  void initState() {
    super.initState();
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar aplicación"),
          content: const Text("¿Estás seguro de que deseas salir de la aplicación?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                exit(0); // Cerrar la aplicación
              },
              child: const Text("Salir"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitConfirmation(context);
        return false; // Evitar el cierre automático
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('imagIA'),
        ),
        body: const Center(
          child: Text('Vista genérica con un texto de prueba'),
        ),
      ),
    );
  }
}
