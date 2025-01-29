import 'dart:io';
import 'package:flutter/material.dart';

class EditableTextField extends StatefulWidget {
  final String title;
  final Function(String) onSubmit;

  const EditableTextField({
    required this.title,
    required this.onSubmit,
    super.key,
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;  // FocusNode para controlar el foco
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
    _focusNode = FocusNode();  // Inicializamos el FocusNode
    _focusNode.addListener(_onFocusChange);  // Agregamos un listener para cambios de foco
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);  // Removemos el listener al desechar el widget
    _focusNode.dispose();  // Liberamos el FocusNode
    super.dispose();
  }

  // Listener para detectar cuando el foco cambia
  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _isEditing = false;  // Cuando pierde el foco, salimos del modo de edición
      });
      widget.onSubmit(_controller.text);  // Llamamos a la función de submit al perder el foco
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing
        ? TextField(
            controller: _controller,
            autofocus: true,
            focusNode: _focusNode,  // Asociamos el FocusNode al TextField
            onSubmitted: (value) {
              setState(() {
                _isEditing = false;
              });
              widget.onSubmit(value);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          )
        : GestureDetector(
            onDoubleTap: () {
              setState(() {
                _isEditing = true;
              });
              FocusScope.of(context).requestFocus(_focusNode);  // Pedimos el foco para el TextField
            },
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 16),
            ),
          );
  }
}
