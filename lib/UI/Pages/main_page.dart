import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/UI/Pages/ExpenseShower.dart';
import 'package:expense_app/UI/Utils/CategoryBottomSheet.dart';
import 'package:expense_app/UI/Utils/category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:
                  CategoryWidget(onCategorySelected: (String selectedCategory) {
                // Handle the category selected
              }),
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
          const Expanded(
            child: ExpenseShower(),
          )
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
              // Here, open the profile and other options
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              onTap: () => Fluttertoast.showToast(
                  msg: "working", toastLength: Toast.LENGTH_LONG),
              // Guide to settings
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
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    Fluttertoast.showToast(
        msg: "User not signed in", toastLength: Toast.LENGTH_SHORT);
    return;
  }

  final textCont = TextEditingController();

  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          width: MediaQuery.of(context).size.width,
          color: const Color.fromRGBO(0, 0, 0, 0.001),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("Expense", style: TextStyle(fontSize: 24))),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
                child: TextField(
                  controller: textCont,
                  decoration: const InputDecoration(
                      labelText: "Enter your expense here!",
                      border: OutlineInputBorder()),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Text("Choose the category!"),
              ),
              CategoryBottomSheet(onSave: (String selectedCategory) {
                onSave(
                    context, textCont.text.trim(), selectedCategory, user.uid);
              })
            ],
          ),
        );
      });
}

Future<void> onSave(
    BuildContext context, String money, String category, String userId) async {
  if (money.isEmpty || category.isEmpty) {
    Fluttertoast.showToast(
        msg: "Please enter a valid expense and category",
        toastLength: Toast.LENGTH_SHORT);
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('data').add({
      'money': money,
      'category': category,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
    });

    Fluttertoast.showToast(
        msg: "Expense added successfully", toastLength: Toast.LENGTH_SHORT);

    Navigator.pop(context); // Close the bottom sheet
  } catch (e) {
    Fluttertoast.showToast(
        msg: "Failed to add expense: $e", toastLength: Toast.LENGTH_LONG);
  }
}
