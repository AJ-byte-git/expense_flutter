import 'package:flutter/material.dart';

class ExpenseTile extends StatelessWidget {
  final String category;
  final String amount;

  const ExpenseTile({
    super.key,
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5), // Adjusted margin
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjusted padding
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Amount: $amount"),
        leading: const Icon(Icons.attach_money),
      ),
    );
  }
}
