import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'viewTest.dart';
import 'package:custom_widget/conection.dart';

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

  @override
  void initState() {
    super.initState();
    _loadServerAndToken();
  }

  Future<String> _getFilePath() async {
    final directory = Directory.current.path;
    return '$directory/$_fileName';
  }

  Future<void> _saveServer() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      final serverData = {'server': _serverController.text, 'token': _token};
      await file.writeAsString(json.encode(serverData));
    } catch (e) {
      print("Error saving server: $e");
    }
  }

  Future<void> _loadServerAndToken() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        final serverJson = await file.readAsString();
        final serverData = json.decode(serverJson);
        setState(() {
          _serverController.text = serverData['server'] ?? '';
          _token = serverData['token'] ?? '';
        });
      }

      if (_token.isNotEmpty && _token != '') {
        _connect(_token);
      }
    } catch (e) {
      print("Error loading server: $e");
    }
  }

  Future<void> _deleteServer() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        _serverController.clear();
      });
    } catch (e) {
      print("Error deleting server: $e");
    }
  }

  void _connect(String token) async {
    final connectionManager = ServerConnectionManager();

    var responseToken = false;
    var responseLogin = '';
    if (token.isNotEmpty || token != '') {
      responseToken = await connectionManager.checkToken(token);
    } else {
      print("No tengo token");
      if (_usernameController.text.isEmpty ||
          _serverController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all the fields')),
        );
        return;
      }
      responseLogin = await connectionManager.loginUser(
          _usernameController.text, _passwordController.text);

      if (responseLogin.isNotEmpty) {
          print("Guardo nuevo token");
        _token = responseLogin;
        _saveServer();
      }
      connectionManager.loginUser(
          _usernameController.text, _passwordController.text);
    }

    if (responseToken || responseLogin != '') {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${_serverController.text}!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ViewTest(connectionManager: connectionManager),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect. Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server Connection')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _serverController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _deleteServer,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _connect(_token),
                  icon: const Icon(Icons.link),
                  label: const Text('Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveServer,
        tooltip: 'Save Server',
        child: const Icon(Icons.save),
      ),
    );
  }
}
