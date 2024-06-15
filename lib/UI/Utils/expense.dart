import 'package:flutter/material.dart';

class Expense extends StatelessWidget {
  final int money;
  final String category;
  final String date;

  const Expense(
      {super.key,
      required this.money,
      required this.category,
      required this.date});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green
          ),
          child:Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [Text("Spent : $money")

                  ],
                ),
              )
            ],
          ),
    ));
  }
}
