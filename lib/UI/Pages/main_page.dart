import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/DataBase/FirestoreService.dart';
import 'package:expense_app/UI/Pages/ExpenseShower.dart';
import 'package:expense_app/UI/Utils/CategoryBottomSheet.dart';
import 'package:expense_app/UI/Utils/category.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class Main_page extends StatefulWidget {
  const Main_page({super.key});

  @override
  State<Main_page> createState() => _Main_pageState();
}

void signOutUser() {
  FirebaseAuth.instance.signOut();
}

class _Main_pageState extends State<Main_page> {
  final FirestoreService _firestoreService = FirestoreService();
  final String docId = 'myVariable'; // Unique ID for your document
  String _variableValue = '';
  final _controller = TextEditingController();
  late Timer _timer;
  final logger = Logger();
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadVariable();
    // Calculate duration until the end of the current month
    Duration durationUntilEndOfMonth = _calculateDurationUntilEndOfMonth();

    // Initialize the timer to run at the end of the current month
    _timer = Timer(durationUntilEndOfMonth, () {
      _updateVariableToZero();
      // Reschedule for next month
      _rescheduleEndOfMonthTask();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkFirstRun(context);
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  Future<void> checkFirstRun(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstRun = prefs.getBool('isFirstRun');

    if (isFirstRun == null || isFirstRun) {
      // Set isFirstRun to false
      await prefs.setBool('isFirstRun', false);

      // Show the showcase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([_one, _two, _three, _four]);
      });
    }
  }

  Future<void> _updateVariableToZero() async {
    try {
      await _firestoreService.updateVariable(docId, '0');
      logger.d("Variable updated successfully");
    } catch (e) {
      logger.e("change failed: $e");
      // Handle error, if any
    }
  }

  void _rescheduleEndOfMonthTask() {
    Duration durationUntilEndOfMonth = _calculateDurationUntilEndOfMonth();
    _timer = Timer(durationUntilEndOfMonth, () {
      _updateVariableToZero();
      // Reschedule for next month
      _rescheduleEndOfMonthTask();
    });
  }

  Duration _calculateDurationUntilEndOfMonth() {
    DateTime now = DateTime.now();
    DateTime endOfMonth = DateTime(now.year, now.month + 1,
        0); // Set to first day of next month and subtract 1 day
    Duration duration = endOfMonth.difference(now);
    return duration;
  }

  Future<void> _loadVariable() async {
    String? value = await _firestoreService.getVariable(docId);
    setState(() {
      _variableValue = value ?? '';
    });
  }

  Future<void> _setVariable(String value) async {
    await _firestoreService.setVariable(docId, value);
    setState(() {
      _variableValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      themeMode: ThemeMode.light,
      theme: FeedbackThemeData(
        background: Colors.white,
            feedbackSheetColor: Colors.red,
        drawColors: [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow
        ]
      ),
      child: Scaffold(
        backgroundColor: Colors.greenAccent,
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
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 15, left: 25),
                              child: StreamBuilder<DocumentSnapshot>(
                                  stream:
                                  _firestoreService.getVariableStream(docId),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return const Text("No data Found");
                                    }
                                    Map<String, dynamic> data = snapshot.data!
                                        .data() as Map<String, dynamic>;
                                    String variableValue =
                                    data['value'] as String;
                                    return Text("Budget: $variableValue",
                                        style: const TextStyle(fontSize: 40));
                                  })),
                        ],
                      ),
                      const Row(
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
                      const Row(
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
          child: const Icon(Icons.add),
        ),
      
        drawer: Drawer(
          backgroundColor: Colors.red,
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
                onTap: () =>
                    Fluttertoast.showToast(
                        msg: "working", toastLength: Toast.LENGTH_LONG),
                // Here, open the profile and other options
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Set Variable"),
                          content: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                                hintText: "Enter new value"),
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () async {
                                  String newValue = _controller.text;
                                  if (newValue.isNotEmpty) {
                                    await _setVariable(newValue);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text("Save"))
                          ],
                        );
                      });
                },
                title: const Text("Set budget"),
              ),
              ListTile(
                  leading: const Icon(Icons.feedback_rounded),
                  title: const Text("Feedback"),
                  onTap: () =>{submitFeedback(context),
                  Navigator.of(context).pop()}
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
      ),
    );
  }
  void submitFeedback(BuildContext context) async {
    BetterFeedback.of(context).show((UserFeedback feedback) {
      //send mail to me
    FlutterEmailSender.send(Email(
      body: "$feedback",
        recipients: ['anirudhagec.genai@gmail.com'],
        isHTML: false
    ));
    });
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
          width: MediaQuery
              .of(context)
              .size
              .width,
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

Future<void> onSave(BuildContext context, String money, String category,
    String userId) async {
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
