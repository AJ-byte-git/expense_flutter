import'package:flutter/material.dart';
class CategoryBottomSheet extends StatefulWidget {
  final Function(String) onSave;

  const CategoryBottomSheet({Key? key, required this.onSave}) : super(key: key);

  @override
  _CategoryBottomSheetState createState() => _CategoryBottomSheetState();
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

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            itemCount: buttonLabels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedIndex == index ? Colors.green.shade500 : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      buttonLabels[index],
                      style: const TextStyle(color: Colors.indigo),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              widget.onSave(buttonLabels[selectedIndex]);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}