import 'package:flutter/material.dart';

class TextInputExample extends StatefulWidget {
  final ValueChanged<String> onTextSaved; // Callback для передачи текста

  TextInputExample({required this.onTextSaved});

  @override
  _TextInputExampleState createState() => _TextInputExampleState();
}

class _TextInputExampleState extends State<TextInputExample> {
  final TextEditingController _controller = TextEditingController();
  String _savedValue = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Введите текст:',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Введите что-нибудь...',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _savedValue = _controller.text;
              });
              widget.onTextSaved(_savedValue); // Передача текста в родительский виджет
            },
            child: Text('Сохранить'),
          ),
          const SizedBox(height: 20),
          Text(
            'Сохраненное значение:',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            _savedValue.isEmpty ? 'Пусто' : _savedValue,
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

