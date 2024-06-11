import 'package:flutter/material.dart';

class CategoryWidget extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryWidget({Key? key, required this.onCategorySelected}) : super(key: key);

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
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

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  void initState() {
    super.initState();
    // Pass the initially selected category when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCategorySelected(buttonLabels[selectedIndex]);
    });
  }

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
          widget.onCategorySelected(buttonLabels[index]);
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
