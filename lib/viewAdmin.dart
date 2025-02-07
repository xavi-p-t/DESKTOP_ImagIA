import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../connection.dart';

class ViewAdmin extends StatefulWidget {
  final token;
  final ServerConnectionManager connectionManager;


  const ViewAdmin({super.key, required this.connectionManager, required this.token});

  @override
  _ViewAdminState createState() => _ViewAdminState();
}

class _ViewAdminState extends State<ViewAdmin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _listUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _listUsers() async {
    try {
      final response = await widget.connectionManager.listAdminUsers();
      final decodedResponse = json.decode(response) as Map<String, dynamic>;

      setState(() {
        _users = (decodedResponse['usuaris'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al obtener los usuarios: $e');
    }
  }

  Future<void> _updateUserPlan(String nickname, String newPlan, String token) async {
    try {
      // Llama al método updateUserPlan desde connectionManager
      final success = await widget.connectionManager.updateUserPlan(
        nickname,
        newPlan,
        token
      );

      // Muestra mensajes en la UI según el resultado
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan actualizado para $nickname a $newPlan.'),
            backgroundColor: Colors.green,
          ),
        );

        // Actualizar la lista localmente si es necesario
        setState(() {
          final userIndex =
              _users.indexWhere((user) => user['nickname'] == nickname);
          if (userIndex != -1) {
            _users[userIndex]['pla'] =
                newPlan; // Actualizar el plan en la lista local
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el plan de $nickname.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Manejo de errores en caso de fallo de conexión u otro problema
      print('Error al actualizar el plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al intentar actualizar el plan.'),
          backgroundColor: Colors.red,
        ),
      );
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
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                exit(0);
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
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.green.withOpacity(0.1),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            ? const Center(child: CircularProgressIndicator())
                            : _users.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay usuarios disponibles.',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _users.length,
                                    itemBuilder: (context, index) {
                                      final user = _users[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              user['nickname'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            DropdownButton<String>(
                                              value: user['pla'], // Plan actual
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'free',
                                                  child: Text('Free'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'premium',
                                                  child: Text('Premium'),
                                                ),
                                              ],
                                              onChanged: (newPlan) {
                                                if (newPlan != null) {
                                                  setState(() {
                                                    user['pla'] = newPlan;
                                                  });
                                                  _updateUserPlan(
                                                    user['nickname'],
                                                    newPlan,
                                                    widget.token
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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
