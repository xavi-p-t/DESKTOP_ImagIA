import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:custom_widget/connection.dart';
import 'package:custom_widget/viewTest.dart'; // Importa correctamente tu clase ViewTest.

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
    _checkInitialToken(); // Revisar token al iniciar la app.
  }

  Future<String> _getFilePath() async {
    final directory = Directory.current.path;
    return p.join(directory, _fileName); // Utiliza path para manejar rutas correctamente.
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
          // Validar token con el servidor
          final isValidToken = await _connectionManager.checkToken(token);

          if (isValidToken) {
            // Token válido, navegar a ViewTest
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ViewTest(connectionManager: _connectionManager),
              ),
            );
            return; // Finaliza el flujo aquí.
          } else {
            print('Token inválido. Se requiere inicio de sesión.');
          }
        } else {
          print('No se encontró un token en el archivo.');
        }
      } else {
        print('Archivo server.json no existe.');
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
      print('Server y token guardados correctamente.');
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
        print('Inicio de sesión exitoso y token guardado.');
        _navigateToViewTest(); // Navegar a ViewTest tras login exitoso.
      } else {
        print('Inicio de sesión fallido.');
      }
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
    }
  }

  Future<void> _navigateToViewTest() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ViewTest(connectionManager: _connectionManager),
      ),
    );
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
      print('Sesión cerrada y configuración eliminada.');
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Connection'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _serverController,
              decoration: const InputDecoration(labelText: 'Server Address'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginAndSaveToken,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
