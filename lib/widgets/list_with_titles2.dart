// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'editable_text_field.dart';
// import '../viewDrive.dart';
// import 'server_control_widget.dart';
// import '../conection.dart';

// class ListWithTitles extends StatefulWidget {
//   final String folderPath;
//   final ServerConnectionManager connectionManager;

//   ListWithTitles({required this.folderPath, required this.connectionManager});

//   @override
//   _ListWithTitlesState createState() => _ListWithTitlesState();
// }

// class FileSystemEntityMock {
//   final String name;
//   final bool isDirectory;

//   FileSystemEntityMock({required this.name, required this.isDirectory});
// }

// class _ListWithTitlesState extends State<ListWithTitles> {
//   late Directory directory;
//   late List<FileSystemEntityMock>
//       filesAndFolders; // Cambiar a FileSystemEntityMock
//   int? _selectedIndex;

//   @override
//   void initState() {
//     super.initState();
//     directory = Directory(widget.folderPath);
//     _loadFiles();
//   }

//   Future<void> _loadFiles() async {
//     try {
//       // Llama al método listFiles de connectionManager para obtener los archivos remotos
//       final remoteFiles =
//           await widget.connectionManager.listFiles(widget.folderPath);

//       setState(() {
//         // Convierte los archivos remotos en un formato adecuado para mostrarlos
//         filesAndFolders = remoteFiles
//             .map((file) => FileSystemEntityMock(
//                   name: file['name']!,
//                   isDirectory: file['type'] == 'directory',
//                 ))
//             .toList();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading files: $e')),
//       );
//     }
//   }

//   // Renombrar un archivo o carpeta
//   Future<void> _renameFile(FileSystemEntityMock entity, String newName) async {
//     final originalPath = '${directory.path}/${entity.name}';
//     try {
//       // Para renombrar un archivo
//       await widget.connectionManager.renameFile(originalPath, newName);
//       _loadFiles();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error renaming: $e')),
//       );
//     }
//   }

//   // Eliminar un archivo o carpeta
//   Future<void> _deleteFile(FileSystemEntityMock entity) async {
//     final originalPath = '${directory.path}/${entity.name}';

//     try {
//       // // Para eliminar un archivo
//       await widget.connectionManager.deleteFile(originalPath);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Archivo o carpeta eliminada: ${entity.name}')),
//       );
//       _loadFiles(); // Actualiza la lista después de eliminar
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error eliminando: $e')),
//       );
//     }
//   }

//   Future<void> _downloadFile(FileSystemEntityMock entity) async {
//     final originalPath = '${directory.path}/${entity.name}';
//     final localPath = './downloads/${entity.name}';
//     try {
//       // Para descargar un archivo
//       await widget.connectionManager.downloadFile(originalPath, localPath);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Descargando archivo: ${entity.name}')),
//       );
//       // Aquí puedes implementar la lógica real de descarga,
//       // como copiar el archivo a otra ubicación o subirlo a un servidor.
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error descargando: $e')),
//       );
//     }
//   }

//   Future<void> _showFileInfo(FileSystemEntityMock entity) async {
//     final originalPath = '${directory.path}/${entity.name}';

//     try {
//       // Para mostrar información de un archivo
//       final fileInfo =
//           await widget.connectionManager.showFileInfo(originalPath);
//       // print(fileInfo);
//       String permisos = fileInfo.split(' ')[0];
//       String info = '';
//       info = 'Nombre: ${entity.name}\n'
//           'Tipo: ${entity.isDirectory ? 'Carpeta' : 'Archivo'}\n'
//           'Permisos: $permisos\n'
//           'Tamaño: ${fileInfo.split(' ')[4]} bytes\n'
//           'Fecha de modificación: ${fileInfo.split(' ')[5]} ${fileInfo.split(' ')[6]} ${fileInfo.split(' ')[7]}';
//       // Mostrar la información en un SnackBar o cualquier otro widget
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(info)),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error mostrando información: $e')),
//       );
//     }

//     // ********************************************
//       //  Hacer que salga las opciones con el mensaje
//         // Si le da a la tuerca y a la opc que sea se llama a esa funcion
//         // El metodo detectServerType tendria que cachear la informacion del tipo de servidor
//         // y devolverla en caso de que ya se haya detectado

// // ********************************************
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: filesAndFolders.length,
//       itemBuilder: (context, index) {
//         final entity = filesAndFolders[index];
//         final isSelected = _selectedIndex == index;
  
//         return GestureDetector(
//             onTap: () {
//               bool isServer = _isServerFolder(entity);
//               if (isServer) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ServerControlWidget(
//                       directory: Directory('${widget.folderPath}/${entity.name}'),
//                       onServerStateChanged: (serverInfo) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text('Servidor actualizado: $serverInfo')),
//                         );
//                       },
//                       connectionManager:
//                           ServerConnectionManager(), // Pasar la conexión SSH al widget del servidor
//                     ),
//                   ),
//                 );
//               } else {
//                 setState(() {
//                   _selectedIndex = index;
//                 });
//               }
//             },
//             // },
//             // child: Column(
//             //   children: [
//             //     // Contenido principal del widget
//             //     Text(entity.name),
//             //     if (_isServerFolder(entity)) // Muestra la notificación si es un servidor
//             //       Container(
//             //         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//             //         color: Colors.grey[200], // Fondo de la notificación
//             //         child: Row(
//             //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //           children: [
//             //             const Text(
//             //               'Servidor detectado',
//             //               style: TextStyle(fontWeight: FontWeight.bold),
//             //             ),
//             //             PopupMenuButton<String>(
//             //               icon: const Icon(Icons.settings), // Icono de la tuerca
//             //               onSelected: (value) async {
//             //                 // Navigator.push(
//             //                 //   context,
//             //                 //   MaterialPageRoute(
//             //                 //     builder: (context) => ServerControlWidget(
//             //                 //       directory: Directory(
//             //                 //           '${widget.folderPath}/${entity.name}'),
//             //                 //       onServerStateChanged: (serverInfo) {
//             //                 //         ScaffoldMessenger.of(context).showSnackBar(
//             //                 //           SnackBar(
//             //                 //               content: Text(
//             //                 //                   'Servidor actualizado: $serverInfo')),
//             //                 //         );
//             //                 //       },
//             //                 //       connectionManager:
//             //                 //           ServerConnectionManager(), // Pasar la conexión SSH al widget del servidor
//             //                 //     ),
//             //                 //   ),
//             //                 // ).then((_) {
//             //                 //   // Encuentra el contexto del `ServerControlWidget`
//             //                 //   final state = context
//             //                 //       .findAncestorStateOfType<_ServerControlWidgetState>();
//             //                 //   if (state != null) {
//             //                 //     switch (value) {
//             //                 //       case 'iniciar':
//             //                 //         state._startServer();
//             //                 //         break;
//             //                 //       case 'aturar':
//             //                 //         state._stopServer();
//             //                 //         break;
//             //                 //       case 'reiniciar':
//             //                 //         state._restartServer();
//             //                 //         break;
//             //                 //     }
//             //                 //   }
//             //                 // });
//             //               },
//             //               itemBuilder: (BuildContext context) => [
//             //                 const PopupMenuItem(
//             //                   value: 'iniciar',
//             //                   child: Text('Iniciar'),
//             //                 ),
//             //                 const PopupMenuItem(
//             //                   value: 'aturar',
//             //                   child: Text('Aturar'),
//             //                 ),
//             //                 const PopupMenuItem(
//             //                   value: 'reiniciar',
//             //                   child: Text('Reiniciar'),
//             //                 ),
//             //               ],
//             //             ),
//             //           ],
//             //         ),
//             //       ),
//             //   ],
//             // ),
//           onDoubleTap: () {
//             if (entity.isDirectory) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ListWithTitles(
//                     folderPath: '${widget.folderPath}/${entity.name}',
//                     connectionManager: widget.connectionManager,
//                   ),
//                 ),
//               );
//             }
//           },
//           child: Material(
//             // Envuelve ListTile en Material
//             child: ListTile(
//               leading: Icon(
//                 entity.isDirectory ? Icons.folder : Icons.insert_drive_file,
//               ),
//               title: EditableTextField(
//                 title: entity.name,
//                 onSubmit: (newName) {
//                   _renameFile(entity, newName);
//                 },
//               ),
//               trailing: isSelected
//                   ? Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.download),
//                           onPressed: () {
//                             _downloadFile(entity);
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.info),
//                           onPressed: () {
//                             _showFileInfo(entity);
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () async {
//                             await _deleteFile(entity);
//                           },
//                         ),
//                       ],
//                     )
//                   : null,
//             ),
//           ),
//         );
//       },
//     );
//   }

// //   return GestureDetector(
// //   onTap: () {
// //     // Verifica si la carpeta es un servidor de tipo NodeJS o Java
// //     bool isServer = _isServerFolder(entity);
// //     if (isServer) {
// //       // Si es un servidor, muestra el widget de control del servidor
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => ServerControlWidget(
// //             directory: Directory('${widget.folderPath}/${entity.name}'),
            // onServerStateChanged: (serverInfo) {
            //   // Captura el mensaje del estado del servidor
            //   print('Estado del servidor: $serverInfo');
            //   // Aquí puedes realizar otras acciones según la información capturada
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text('Servidor actualizado: $serverInfo')),
            //   );
            // },
// //           ),
// //         ),
// //       );
// //     } else {
// //       setState(() {
// //         _selectedIndex =
// //             index; // Actualiza el índice del elemento seleccionado
// //       });
// //     }
// //   },
// //   onDoubleTap: () {
// //     if (entity.isDirectory) {
// //       // Si es una carpeta, navega a la vista de la carpeta
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => ListWithTitles(
// //             folderPath: '${widget.folderPath}/${entity.name}',
// //             connectionManager: widget.connectionManager,
// //           ),
// //         ),
// //       );
// //     }
// //   },
// // );

//   bool _isServerFolder(FileSystemEntityMock entity) {
//     // Aquí verificas si la carpeta contiene archivos o características de un servidor NodeJS o Java
//     final folderName = entity.name.toLowerCase();
//     return folderName.contains('nodejs') || folderName.contains('java');
//   }
// }
