import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import '../conection.dart';
import 'widgets/list_with_titles.dart';

class ViewDrive extends StatefulWidget {
  final String folderPath;
  final ServerConnectionManager connectionManager;

  const ViewDrive(
      {super.key, required this.folderPath, required this.connectionManager});

  @override
  _ViewDriveState createState() => _ViewDriveState();
}

class _ViewDriveState extends State<ViewDrive> {
  late Directory directory;
  List<String> deletedFiles = [];
  List<String> modifiedFiles = []; 
  final GlobalKey<ListWithTitlesState> _listKey =
      GlobalKey<ListWithTitlesState>();

  @override
  void initState() {
    super.initState();
    directory = Directory(widget.folderPath);
  }

  void _showExitConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Cerrar aplicación"),
        content: const Text("¿Estás seguro de que deseas salir de la aplicación?"),
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


  Future<void> _pickAndUploadEntity() async {
    try {
      // Mostrar un fitxer o carpeta
      final choice = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Selecciona tipus de pujada'),
            content: const Text('Què vols pujar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'file'),
                child: const Text('Fitxer'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'folder'),
                child: const Text('Carpeta'),
              ),
            ],
          );
        },
      );

      if (choice == null) {
        return;
      }

      if (choice == 'file') {
        // Mostrar diàleg per seleccionar un fitxer
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.any,
        );

        if (result != null && result.files.single.path != null) {
          final localPath = result.files.single.path!;
          final fileName = result.files.single.name;
          final remotePath = '${widget.folderPath}/$fileName';

          await _uploadFile(localPath, remotePath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No s\'ha seleccionat cap fitxer.')),
          );
        }
      } else if (choice == 'folder') {
        // Mostrar diàleg per seleccionar una carpeta
        final selectedFolderPath = await getDirectoryPath(
          confirmButtonText: 'Selecciona Carpeta',
        );

        if (selectedFolderPath != null) {
          await _uploadCompressedFolder(selectedFolderPath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No s\'ha seleccionat cap carpeta.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _uploadCompressedFolder(String localPath) async {
    try {
      final zipFilePath = await _compressFolder(localPath);
      final zipFileName = p.basename(zipFilePath);
      final remoteZipPath = '${widget.folderPath}/$zipFileName';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pujant carpeta comprimida...')),
        );
      }

      await widget.connectionManager.uploadFile(zipFilePath, remoteZipPath);
      File(zipFilePath).deleteSync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carpeta comprimida i pujada correctament!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en pujar la carpeta: $e')),
        );
      }
    }
  }

  Future<String> _compressFolder(String folderPath) async {
    final folder = Directory(folderPath);
    if (!folder.existsSync()) {
      throw Exception("La carpeta no existeix: $folderPath");
    }

    final zipFileName = '${folder.path.split(Platform.pathSeparator).last}.zip';
    final zipFile = File('${folder.parent.path}/$zipFileName');
    final archive = Archive();

    await for (var entity in folder.list(recursive: true)) {
      if (entity is File) {
        final fileBytes = await entity.readAsBytes();
        final filePath =
            entity.path.replaceFirst(folder.parent.path + Platform.pathSeparator, '');
        archive.addFile(ArchiveFile(filePath, fileBytes.length, fileBytes));
      }
    }

    final zipBytes = ZipEncoder().encode(archive);
    await zipFile.writeAsBytes(zipBytes);

    return zipFile.path;
  }

  Future<void> _uploadFile(String localPath, String remotePath) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pujant fitxer...')),
        );
      }

        await widget.connectionManager.uploadFile(localPath, remotePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitxer pujat correctament!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en pujar el fitxer: $e')),
        );
      }
    }
  }

  void sendMessageToChild(String path) {
    if (_listKey.currentState != null) {
      print('Enviando goBack al hijo con path: $path');
      _listKey.currentState!.goBack(path); // Llamar al método del hijo
    } else {
      print('El estado del hijo aún no está listo.');
    }
  }

  void _showModifiedFiles() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Arxius modificats'),
          content: modifiedFiles.isEmpty
              ? const Text('No hi ha arxius modificats.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: modifiedFiles.length,
                    itemBuilder: (context, index) {
                      final fileName = p.basename(modifiedFiles[index]);
                      return ListTile(
                        title: Text(fileName),
                        subtitle: Text(modifiedFiles[index]),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proxmox Drive - ${directory.path.split('\\').last}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Simplemente recargar la vista si es necesario
              // home/super/carpeta_test  ***********
              // final path =
              //     '${_listKey.currentState!.actualPath.split('/')[0]}/${_listKey.currentState!.actualPath.split('/')[1]}';
              print(directory.path);
              sendMessageToChild(directory.path);
            },
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () {
              _showExitConfirmation(context);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Recents'),
                  onTap: () {
                    _showModifiedFiles();
                  },
                ),
                ListTile(
                  title: const Text('Carpetes'),
                  selected: true,
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Eliminats'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Arxius eliminats'),
                          content: deletedFiles.isEmpty
                              ? const Text('No hi ha arxius eliminats.')
                              : SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    itemCount: deletedFiles.length,
                                    itemBuilder: (context, index) {
                                      final fileName = p.basename(deletedFiles[index]);
                                      return ListTile(
                                        title: Text(fileName),
                                        subtitle: Text(deletedFiles[index]),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.restore),
                                          onPressed: () async {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Restaurar no implementat per a : $fileName')),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              // Volver a la carpeta padre
                              final parentPath = directory.parent.path;
                              setState(() {
                                directory = Directory(
                                    parentPath); // Actualiza la ruta en el padre
                              });
                              sendMessageToChild(
                                  parentPath); // Envía la nueva ruta al hijo
                            },
                          ),
                          Text(
                            directory.path.split('\\').last,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _pickAndUploadEntity,
                        child: const Text('Afegir fitxers o carpetes'),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Ordenar segons: Nom',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ),
                const Divider(),
                Expanded(
                  // child: Builder(
                  //   builder: (context) {
                  //     return ListWithTitles(
                  //       key: _listKey, // Asignar el GlobalKey aquí
                  //       folderPath: directory.path,
                  //       connectionManager: widget.connectionManager,
                  //     );

                  child: ListWithTitles(
                    key: _listKey, // Asignar el GlobalKey aquí
                    folderPath: directory.path,
                    connectionManager: widget.connectionManager,
                    onPathChanged: (newPath) {
                      setState(() {
                        directory =
                            Directory(newPath); // Actualiza la ruta en el padre
                      });
                    },
                    onFileDeleted: (deletedFilePath) {
                      setState(() {
                        deletedFiles.add(deletedFilePath);
                      });
                    },
                    onFileModified: (modifiedFilePath) {
                      setState(() {
                        modifiedFiles.add(modifiedFilePath);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
