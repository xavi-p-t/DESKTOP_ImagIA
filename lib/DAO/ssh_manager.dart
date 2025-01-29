// import 'package:ssh2/ssh2.dart';

// class SSHManager {
//   static final SSHManager _instance = SSHManager._internal();
//   late SSHClient _client;

//   factory SSHManager() {
//     return _instance;
//   }

//   SSHManager._internal();

//   Future<void> connect({
//     required String host,
//     required int port,
//     required String username,
//     required String privateKey,
//   }) async {
//     _client = SSHClient(
//       host: host,
//       port: port,
//       username: username,
//       privateKey: privateKey,
//     );
//     await _client.connect();
//   }

//   Future<void> disconnect() async {
//     await _client.disconnect();
//   }

//   Future<List<Map<String, String>>> listFiles(String remotePath) async {
//     try {
//       final result = await _client.execute('ls -l $remotePath');
//       final files = <Map<String, String>>[];

//       for (var line in result.split('\n')) {
//         if (line.isNotEmpty) {
//           final parts = line.split(RegExp(r'\s+'));
//           final isDirectory = parts[0].startsWith('d');
//           final name = parts.last;
//           files.add({
//             'name': name,
//             'type': isDirectory ? 'directory' : 'file',
//           });
//         }
//       }
//       return files;
//     } catch (e) {
//       throw Exception('Error listing files: $e');
//     }
//   }
// }
