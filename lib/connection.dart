import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

class ServerConnectionManager {
  static final ServerConnectionManager _instance =
      ServerConnectionManager._internal();

  ServerConnectionManager._internal();

  factory ServerConnectionManager() => _instance;

  String? _currentUsername;
  String? _currentServer;
  int? _currentPort;
  String? _currentPrivateKeyPath;

  SSHClient? _sshClient;

  void setConnection(
      String username, String server, int port, String privateKeyPath) {
    _currentUsername = username;
    _currentServer = server;
    _currentPort = port;
    _currentPrivateKeyPath = privateKeyPath;

    print("Connection details set:");
    print(
        "Username: $_currentUsername, Server: $_currentServer, Port: $_currentPort");
  }

  Future<void> connect() async {
    if (_currentServer == null ||
        _currentPort == null ||
        _currentUsername == null ||
        _currentPrivateKeyPath == null) {
      throw Exception("Connection details are not set.");
    }

    try {
      final socket = await SSHSocket.connect(_currentServer!, _currentPort!);

      final privateKeyPem = await File(_currentPrivateKeyPath!).readAsString();

      _sshClient = SSHClient(
        socket,
        username: _currentUsername!,
        identities: [
          ...SSHKeyPair.fromPem(privateKeyPem),
        ],
      );

      print("Successfully connected to $_currentServer on port $_currentPort.");
    } catch (e) {
      print("Error while connecting: $e");
      throw Exception("Failed to connect to the SSH server: $e");
    }
  }

 
  /// Cerrar la conexión SSH.
  Future<void> disconnect() async {
    if (_sshClient != null) {
      _sshClient!.close();

      await _sshClient!.done;

      _sshClient = null;
      print("Disconnected from the SSH server.");
    } else {
      print("No SSH client to disconnect.");
    }
  }

  // Método para registrar un usuario en el sistema
  Future<void> registerUser(
      String telefon, String nickname, String email, String password) async {
    final url = Uri.parse('https://imagia1.ieti.site/api/usuaris/registrar');

    // Crea el cuerpo de la solicitud como un mapa (map)
    final Map<String, String> requestBody = {
      'telefon': telefon,
      'nickname': nickname,
      'email': email,
      'password': password,
    };

    try {
      // Enviar la solicitud POST con los parámetros necesarios
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Manejo de la respuesta
      if (response.statusCode == 200) {
        // Si la respuesta es exitosa
        final responseData = json.decode(response.body);
        print('Usuario registrado con éxito: ${responseData['message']}');
        // Puedes hacer algo con la respuesta si es necesario, como mostrar un mensaje en la interfaz
      } else {
        // Si la respuesta es un error
        print('Error al registrar el usuario: ${response.body}');
      }
    } catch (e) {
      // Manejar errores de conexión o cualquier otro error
      print('Error al hacer la solicitud: $e');
    }
  }

  // Método para loggear un usuario en el sistema
  Future<String> loginUser(String nickname, String password) async {
    final url = Uri.parse('https://imagia1.ieti.site/api/admin/usuaris/login');

    // Crea el cuerpo de la solicitud como un mapa (map)
    final Map<String, String> requestBody = {
      'nickname': nickname,
      'password': password,
    };

    try {
      // Enviar la solicitud POST con los parámetros necesarios
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Manejo de la respuesta
      if (response.statusCode == 200) {
        // Si la respuesta es exitosa
        final responseData = json.decode(response.body);
        print('Usuario loggeado con éxito: ${responseData['message']}');
        return responseData['api_token'];

      } else {
        // Si la respuesta es un error
        print('Error al hacer log in con este usuario: ${response.body}');
        return '';
      }
    } catch (e) {
      // Manejar errores de conexión o cualquier otro error
      print('Error al hacer la solicitud: $e');
      return '';
    }
  }

  // Método para loggear un usuario en el sistema
  Future<bool> checkToken(String token) async {
    final url = Uri.parse(
        'https://imagia1.ieti.site/api/admin/usuaris/verificar-token');

    // Crea el cuerpo de la solicitud como un mapa (map)
    final Map<String, String> requestBody = {
      'token': token,
    };

    try {
      // Enviar la solicitud POST con los parámetros necesarios
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Manejo de la respuesta
      if (response.statusCode == 200) {
        // Si la respuesta es exitosa
        final responseData = json.decode(response.body);
        print('Token vaido: ${responseData['message']}');
        return true;
      } else {
        // Si la respuesta es un error
        print('Token invalido: ${response.body}');
        return false;
      }
    } catch (e) {
      // Manejar errores de conexión o cualquier otro error
      print('Error al hacer la solicitud: $e');
      return false;
    }
  }
}
