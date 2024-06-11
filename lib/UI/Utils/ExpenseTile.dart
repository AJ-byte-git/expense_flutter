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
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text("Amount: $amount"),
        leading: const Icon(Icons.attach_money),
      ),
    );
  }
}
