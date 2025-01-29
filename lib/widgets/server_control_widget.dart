import 'package:flutter/material.dart';
import '../conection.dart';
import 'portRedirectWidget.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ServerControlWidget extends StatefulWidget {
  final String serverPath;
  final void Function(Map<String, dynamic> serverInfo) onServerStateChanged;
  final ServerConnectionManager connectionManager;

  const ServerControlWidget({
    required this.serverPath,
    required this.onServerStateChanged,
    required this.connectionManager,
    Key? key,
  }) : super(key: key);

  @override
  _ServerControlWidgetState createState() => _ServerControlWidgetState();
}

class _ServerControlWidgetState extends State<ServerControlWidget> {
  bool _isServerRunning = false;

  Future<String> _detectServerType() async {
    final remotePath = widget.serverPath;

    try {
      final files = await widget.connectionManager.listFiles(remotePath);

      if (files.any((file) => file['name'] == 'package.json')) {
        return 'Node';
      } else {
        return 'Java';
      }
    } catch (e) {
      print('Error detecting server type: $e');
      return 'Unknown';
    }
  }

  void _notifyParent() async {
    final serverType = await _detectServerType();
    widget.onServerStateChanged({
      'isServer': serverType != 'Unknown',
      'type': serverType,
      'active': _isServerRunning,
    });
  }

  Future<void> handleServerAction(String action, String serverPath) async {
    final port = 3000;
    final serverType = await _detectServerType();

    try {
      switch (action) {
        case 'start':
          setState(() {
            _isServerRunning = true;
          });
          _notifyParent();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Iniciando servidor...')),
          );
          await widget.connectionManager.startServer(serverPath, serverType.toLowerCase(), port);
          break;

        case 'restart':
          setState(() {
            _isServerRunning = true;
          });
          _notifyParent();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reiniciando servidor...')),
          );
          await widget.connectionManager.restartServer(serverPath, serverType.toLowerCase(), port);
          break;

        case 'stop':
          setState(() {
            _isServerRunning = false;
          });
          _notifyParent();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deteniendo servidor...')),
          );
          await widget.connectionManager.stopServer(serverType, port);
          break;

        default:
          throw Exception('Acción desconocida: $action');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al ejecutar acción $action: $e')),
      );
    }
  }


 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _detectServerType(),
      builder: (context, snapshot) {
        final serverType = snapshot.data ?? 'Detectando...';

        return Padding(
          padding: const EdgeInsets.all(16.0),  // Agregamos un poco de espacio alrededor del widget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Servidor encontrado: $serverType',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      CircleIndicator(isActive: _isServerRunning),  // Indicador de estado
                      const SizedBox(width: 10),  // Separación entre el círculo y el ícono
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.blue),
                        tooltip: 'Configurar redirección de puertos',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PortRedirectWidget()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (serverType != 'Unknown') ...[
                if (_isServerRunning) ...[
                  ElevatedButton(
                    onPressed: () => handleServerAction('restart', widget.serverPath),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.orange.shade600,  // Color de fondo
                    ),
                    child: const Text('Reiniciar servidor'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => handleServerAction('stop', widget.serverPath),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.red.shade600,  // Color de fondo
                    ),
                    child: const Text('Detener servidor'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => handleServerAction('start', widget.serverPath),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.green.shade600,  // Color de fondo
                      foregroundColor: Colors.white,  // Letra en blanco
                    ),
                    child: const Text('Iniciar servidor'),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              // Aquí añadimos el SVG en el centro y con un tamaño de aproximadamente el 25% de la pantalla
              Expanded(
                child: Center(  // Centra el SVG en la pantalla
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.25,  // 25% del ancho de la pantalla
                    height: MediaQuery.of(context).size.height * 0.25,  // 25% de la altura de la pantalla
                    child: SvgPicture.asset(
                      'assets/data/your_image.svg', // Asegúrate de poner la ruta correcta de tu archivo SVG
                      fit: BoxFit.contain, // Ajusta la imagen para que ocupe el espacio
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
class CircleIndicator extends StatelessWidget {
  final bool isActive;

  const CircleIndicator({required this.isActive, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? Colors.green.shade200 : Colors.red.shade200,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}