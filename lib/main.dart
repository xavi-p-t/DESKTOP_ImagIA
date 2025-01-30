import 'dart:convert';
import 'dart:io';
import 'package:custom_widget/conection.dart';
import 'package:flutter/material.dart';
import 'viewTest.dart'; // Importa la página de detalles
import 'custom_painters/selected_item_painter.dart';

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
  final List<Map<String, dynamic>> _servers = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int? _selectedServerIndex;
  final String _fileName = 'servers.json';

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<String> _getFilePath() async {
    final directory = Directory.current.path;
    return '$directory/$_fileName';
  }

  Future<void> _saveServers() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      final serversJson = json.encode(_servers);
      await file.writeAsString(serversJson);
    } catch (e) {
      print("Error saving servers: $e");
    }
  }

  Future<void> _loadServers() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        final serversJson = await file.readAsString();
        setState(() {
          _servers.addAll(List<Map<String, dynamic>>.from(json.decode(serversJson)));
        });
      }
    } catch (e) {
      print("Error loading servers: $e");
    }
  }

  void _addServer() {
    setState(() {
      _servers.add({
        'username': _usernameController.text,
        'server': _serverController.text,
        'password': _passwordController.text,
        'favorite': false,
      });
      _clearInputs();
    });
    _saveServers();
  }

  void _deleteServer() {
    if (_selectedServerIndex != null) {
      setState(() {
        _servers.removeAt(_selectedServerIndex!);
        _clearInputs();
        _selectedServerIndex = null;
      });
      _saveServers();
    }
  }

  void _toggleFavorite() {
    if (_selectedServerIndex != null) {
      setState(() {
        _servers[_selectedServerIndex!]['favorite'] =
            !_servers[_selectedServerIndex!]['favorite'];
      });
      _saveServers();
    }
  }

  void _connect() async {
    if (_selectedServerIndex != null) {
      final selectedServer = _servers[_selectedServerIndex!];

      if (selectedServer['username'] == '' ||
          selectedServer['server'] == '' ||
          selectedServer['password'] == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all the fields')),
        );
        return;
      }

      final connectionManager = ServerConnectionManager();

      // connectionManager.setConnection(
      //   selectedServer['username'],
      //   selectedServer['server'],
      //   selectedServer['password'],
      // );

      connectionManager.registerUser('000000000', selectedServer['username'], 'test@test.com', selectedServer['password']);

      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${selectedServer['server']}!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewTest(connectionManager: connectionManager),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect. Error: $e')),
        );
      }
    }
  }

  void _clearInputs() {
    _usernameController.clear();
    _serverController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Connection'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _servers.length,
              itemBuilder: (context, index) {
                final server = _servers[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedServerIndex = index;
                      _usernameController.text = server['username'];
                      _serverController.text = server['server'];
                      _passwordController.text = server['password'];
                    });
                  },
                  child: CustomPaint(
                    painter: SelectedItemPainter(
                      isSelected: index == _selectedServerIndex,
                    ),
                    child: ListTile(
                      title: Text(
                        server['server'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        server['username'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Icon(
                        server['favorite'] ? Icons.star : Icons.star_border,
                        color: server['favorite'] ? Colors.yellow : Colors.grey,
                      ),
                      selected: index == _selectedServerIndex,
                    ),
                  ),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _serverController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
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
                        onPressed: _toggleFavorite,
                        icon: const Icon(Icons.star),
                        label: const Text('Favorite'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _connect,
                        icon: const Icon(Icons.link),
                        label: const Text('Connect'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addServer,
        tooltip: 'Add Server',
        child: const Icon(Icons.add),
      ),
    );
  }
}
