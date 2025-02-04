import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart'; // Para la animación
import '../connection.dart';

class ViewTest extends StatefulWidget {
  final ServerConnectionManager connectionManager;

  const ViewTest({super.key, required this.connectionManager});

  @override
  _ViewTestState createState() => _ViewTestState();
}

class _ViewTestState extends State<ViewTest> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar el controlador y animación de fade
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Duración de la animación
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward(); // Iniciar la animación
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberar recursos del controlador
    super.dispose();
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
        body: Stack(
          children: [
            // Fondo verde claro
            Container(
              color: Colors.green.withOpacity(0.1),
            ),
            // Contenido principal con animación
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Franja verde superior con el título
                  Container(
                    height: 250,
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: const Text(
                      'imagIA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Panel principal con información de prueba
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Vista genérica con un texto de prueba',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
