import 'package:flutter/material.dart';

class GridDialogExample extends StatelessWidget {
  final bool openClousDialog;
  final List<String> items;
  final void Function(String) onItemTap;

  const GridDialogExample({Key? key,
    required this.openClousDialog,
    required this.items,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: openClousDialog,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border.all(
              color: Colors.blueGrey.shade700,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 30.0,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          width: 300, // Ширина контейнера
          height: 500, // Высота контейнера
          child: Column(
            children: [
              const Text(
                'Выберите элемент',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          onItemTap(items[index]);
                        },
                        child: Text(items[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
