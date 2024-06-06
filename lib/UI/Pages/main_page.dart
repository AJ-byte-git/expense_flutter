import 'package:expense_app/UI/Utils/category.dart';
import 'package:expense_app/UI/Utils/expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Main_page extends StatefulWidget {
  const Main_page({super.key});

  @override
  State<Main_page> createState() => _Main_pageState();
}

void signOutUser() {
  FirebaseAuth.instance.signOut();
}
class _Main_pageState extends State<Main_page> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
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
          Expanded(
              child: Container(
            height: 900,
            margin: const EdgeInsets.all(10),
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [Expense(money: 11, category: "test", date: "test")],
            ),
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheetDialog(context);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: [
            GestureDetector(
              child: const DrawerHeader(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 100,
                    ),
                    Text("//User Name")
                  ],
                ),
              ),
              onTap: () => Fluttertoast.showToast(
                  msg: "working", toastLength: Toast.LENGTH_LONG),
              //here open the profile and all
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              onTap: () => Fluttertoast.showToast(
                  msg: "working", toastLength: Toast.LENGTH_LONG),
              //guide to settings
              title: const Text("Settings"),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_rounded),
              title: const Text("Feedback"),
              onTap: () => Fluttertoast.showToast(
                  msg: "working", toastLength: Toast.LENGTH_SHORT),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log Out"),
              onTap: () {
                Navigator.pop(context);
                signOutUser();
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showBottomSheetDialog(BuildContext context) {
  final textCont = TextEditingController();
  showModalBottomSheet(context: context, builder: (BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height ,
      width: MediaQuery.of(context).size.width,
      color: const Color.fromRGBO(0, 0, 0, 0.001),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: textCont,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Expense Here!!"),
            ),
          )
        ],
      ),
    );
  });
}
