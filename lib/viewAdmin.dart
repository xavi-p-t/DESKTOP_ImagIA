import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../connection.dart';

class ViewAdmin extends StatefulWidget {
  final ServerConnectionManager connectionManager;

  const ViewAdmin({super.key, required this.connectionManager});

  @override
  _ViewAdminState createState() => _ViewAdminState();
}

class _ViewAdminState extends State<ViewAdmin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _users = []; // Lista para almacenar los usuarios
  bool _isLoading =
      true; // Para mostrar un indicador de carga mientras se obtienen los usuarios

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
    _listUsers(); // Cargar usuarios al iniciar la vista
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberar recursos del controlador
    super.dispose();
  }

  Future<void> _listUsers() async {
    try {
      final response = await widget.connectionManager.listAdminUsers();

      // Decodifica la respuesta como un Map
      final decodedResponse = json.decode(response) as Map<String, dynamic>;

      setState(() {
        // Extrae la lista de usuarios dentro de la clave "usuaris"
        _users = (decodedResponse['usuaris'] as List<dynamic>)
            .cast<Map<String, dynamic>>(); // Asegurarse de que es una lista
        _isLoading = false; // Indicar que se ha terminado de cargar
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Detener la carga incluso si ocurre un error
      });
      print('Error al obtener los usuarios: $e');
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar aplicación"),
          content:
              const Text("¿Estás seguro de que deseas salir de la aplicación?"),
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
                  // Panel principal con la lista de usuarios
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
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator()) // Indicador de carga
                            : _users.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay usuarios disponibles.',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  )
                                : SingleChildScrollView( // Agregado el scroll
                                    child: Column( // Mostrar la lista de usuarios verticalmente
                                      children: _users
                                          .map((user) => Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Align(  // Alinear a la izquierda
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    width: double.infinity,  // Ocupa todo el ancho
                                                    child: Chip(
                                                      label: Text(
                                                        user['nickname'], // Mostramos el nickname
                                                        style: const TextStyle(
                                                          fontSize: 18, // Aumentar el tamaño de la fuente
                                                          fontWeight: FontWeight.bold, // Hacerla más prominente
                                                        ),
                                                      ),
                                                      backgroundColor: Colors.green.withOpacity(0.2),
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
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
