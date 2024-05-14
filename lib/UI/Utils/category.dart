import 'package:flutter/material.dart';

class category extends StatefulWidget {
  const category({super.key});

  @override
  State<category> createState() => _categoryState();
}

List<String> buttonLabels = [
  "General",
  "Bus fare",
  "Stationary",
  "Food",
  "Snacks",
  "Study",
  "Travel",
  "Friend"
];
int selectedIndex = 0;
TextEditingController textEditingController = TextEditingController();

class _categoryState extends State<category> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        buttonLabels.length,
        (index) => _buildButton(buttonLabels[index], index),
      ),
    );
  }

  Widget _buildButton(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedIndex = index;
          });
          //Sort functionality will be added here
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              index == selectedIndex ? Colors.green.shade500 : Colors.red),
        ),
        child: GestureDetector(
          onLongPress: () {
            _deleteItem(index);
          },
          child: Text(
            text,
            style: const TextStyle(color: Colors.indigo),
          ),
        ),
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      buttonLabels.removeAt(index);
    });
  }
}
