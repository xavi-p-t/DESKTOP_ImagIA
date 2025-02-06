import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:custom_widget/connection.dart';
import 'package:custom_widget/viewAdmin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server Connection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ServerConnectionPage(),
    );
  }
}

class ServerConnectionPage extends StatefulWidget {
  const ServerConnectionPage({super.key});

  @override
  State<ServerConnectionPage> createState() => _ServerConnectionPageState();
}

class _ServerConnectionPageState extends State<ServerConnectionPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _token = '';
  final String _fileName = 'server.json';

  final ServerConnectionManager _connectionManager = ServerConnectionManager();

  @override
  void initState() {
    super.initState();
    _checkInitialToken();
    _loadSavedServer();
  }

  Future<String> _getFilePath() async {
    final directory = Directory.current.path;
    return p.join(directory, _fileName);
  }

  Future<void> _loadSavedServer() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        final serverJson = await file.readAsString();
        final serverData = json.decode(serverJson);
        final String savedServer = serverData['server'] ?? '';
        if (savedServer.isNotEmpty) {
          setState(() {
            _serverController.text = savedServer;
          });
        }
      }
    } catch (e) {
      print('Error al cargar el servidor guardado: $e');
    }
  }

  Future<void> _checkInitialToken() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        final serverJson = await file.readAsString();
        final serverData = json.decode(serverJson);
        final String token = serverData['token'] ?? '';

        if (token.isNotEmpty) {
          final isValidToken = await _connectionManager.checkToken(token);

          if (isValidToken) {
            _showNotification('Inicio de sesión exitoso', Colors.green);
            _navigateToViewAdmin();
            return;
          }
        }
      }
    } catch (e) {
      print('Error al verificar el token: $e');
    }
  }

  Future<void> _saveServer() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      final serverData = {'server': _serverController.text, 'token': _token};
      await file.writeAsString(json.encode(serverData));
    } catch (e) {
      print("Error guardando el servidor: $e");
    }
  }

  Future<void> _loginAndSaveToken() async {
    final nickname = _usernameController.text;
    final password = _passwordController.text;

    try {
      final token = await _connectionManager.loginUser(nickname, password);
      if (token.isNotEmpty) {
        setState(() {
          _token = token;
        });
        await _saveServer();
        _showNotification('Inicio de sesión exitoso', Colors.green);
        _navigateToViewAdmin();
      }
      else {
        _showNotification('Usuario o contraseña incorrectos.', Colors.red);
      }
    } catch (e) {
      _showNotification('Error en el inicio de sesión', Colors.red);
      print('Error durante el inicio de sesión: $e');
    }
  }

  Future<void> _navigateToViewAdmin() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAdmin(connectionManager: _connectionManager),
      ),
    );
  }

  void _showNotification(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _logout() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        _serverController.clear();
        _token = '';
      });
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo verde claro
          Container(
            color: Colors.green.withOpacity(0.1),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Panel verde del título
              Container(
                height: 250, // Altura de la franja verde
                color: Colors.green,
                alignment: Alignment.center,
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Margen superior después de la franja verde
              const SizedBox(height: 24),
              // Formulario
              Padding(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _serverController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.cloud),
                          labelText: 'Server Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Username or Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loginAndSaveToken,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
