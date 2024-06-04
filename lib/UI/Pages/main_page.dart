import 'package:expense_app/UI/Utils/category.dart';
import 'package:expense_app/UI/Utils/expense.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class main_page extends StatefulWidget {
  const main_page({super.key});

  @override
  State<main_page> createState() => _main_pageState();
}

class _main_pageState extends State<main_page> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          onPressed: () {
            Fluttertoast.showToast(
              msg: "Working",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          },
          icon: const Icon(Icons.menu),
        ),
        centerTitle: true,
        title: const Text(
          "Expense Report",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(20)),
                height: 200,
                width: 380,
                child: const Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 15, left: 25),
                          child: Text(
                            "//budget",
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 25, top: 10),
                          child: Text(
                            "Money spent : ",
                            style: TextStyle(fontSize: 24),
                          ),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 25),
                          child: Text(
                            "//remaining",
                            style: TextStyle(fontSize: 38),
                          ),
                        ),
                      ],
                    )
                  ],
                )),
          ),
          const Divider(color: Colors.black87, height: 2),
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: category(),
            ),
          ),
          const Divider(
            color: Colors.black87,
            height: 2,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
            child: Row(children: [
              Text(
                "Expenses so far :",
                style: TextStyle(fontSize: 18),
              )
            ]),
          ),
          Container(
            child: Expanded(
                child: Container(
              height: 900,
              margin: const EdgeInsets.all(10),
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [Expense(money: 11, category: "test", date: "test")],
              ),
            )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Fluttertoast.showToast(
              msg: "working", toastLength: Toast.LENGTH_LONG);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
