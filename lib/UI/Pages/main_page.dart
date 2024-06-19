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
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class Main_page extends StatefulWidget {
  const Main_page({super.key});

  @override
  State<Main_page> createState() => _Main_pageState();
}

void signOutUser() {
  FirebaseAuth.instance.signOut();
}

class _Main_pageState extends State<Main_page> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  String _variableValue = '';
  final _controller = TextEditingController();
  late Timer _timer;
  final logger = Logger();
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String sortCat = "";
  int money_spent = 0;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadVariable();
      // Calculate duration until the end of the current month
      Duration durationUntilEndOfMonth = _calculateDurationUntilEndOfMonth();

      // Initialize the timer to run at the end of the current month
      _timer = Timer(durationUntilEndOfMonth, () {
        _updateVariableToZero();
        // Reschedule for next month
        _rescheduleEndOfMonthTask();
      });
    }
    getTotalMoney(user!.uid);
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  Color calculateRemainingMoneyColor() {
    if (money_spent >= (int.tryParse(_variableValue)??0)) {
      return Colors
          .red; // If money spent is greater than variable value, return red color
    } else {
      return Colors
          .green; // Otherwise, return black color (or any other default color)
    }
  }

  Future<void> _updateVariableToZero() async {
    if (user != null) {
      try {
        await _firestoreService.updateVariable(user!.uid, '0');
        logger.d("Variable updated successfully");
      } catch (e) {
        logger.e("Change failed: $e");
        // Handle error, if any
      }
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
    if (user != null) {
      String? value = await _firestoreService.getVariable(user!.uid);
      setState(() {
        _variableValue = value!;
      });
    }
  }

  Future<void> _setVariable(String value) async {
    if (user != null) {
      await _firestoreService.setVariable(user!.uid, value);
      setState(() {
        _variableValue = value;
      });
    }
  }

  Future<void> deleteUserData(BuildContext context) async {
    if (user != null) {
      String uid = user!.uid;

      try {
        // Re-authenticate the user with Google Sign-In
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // The user canceled the sign-in
          logger.e("Google sign-in was canceled by the user.");
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await user!.reauthenticateWithCredential(credential);

        // Delete user document from Firestore
        await _firestore.collection('users').doc(uid).delete();

        // Delete other collections or documents associated with the user if necessary
        QuerySnapshot postsSnapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('posts')
            .get();

        for (DocumentSnapshot ds in postsSnapshot.docs) {
          await ds.reference.delete();
        }

        // Delete the user from Firebase Auth
        await user!.delete();
        logger.d("Data deleted successfully");

        // Sign out the user and navigate back
        await googleSignIn.signOut();
        signOutUser();
        Navigator.of(context).pop();
      } catch (e) {
        logger.e("There was an error: $e");
        // Optionally, show a dialog with the error message to the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('There was an error deleting your data: $e'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      themeMode: ThemeMode.light,
      theme: FeedbackThemeData(
          background: Colors.white,
          feedbackSheetColor: Colors.red,
          drawColors: [Colors.red, Colors.green, Colors.blue, Colors.yellow]),
      child: Scaffold(
        backgroundColor: Colors.cyan,
        appBar: AppBar(
          backgroundColor: Colors.teal,
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
            "Expense Tracker",
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent,
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
                                  stream: _firestoreService
                                      .getVariableStream(user!.uid),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return const Text(
                                        "Budget: 0",
                                        style: TextStyle(fontSize: 40),
                                      );
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25, top: 10),
                            child: Text(
                              "Money spent : $money_spent",
                              style: const TextStyle(fontSize: 24),
                            ),
                          )
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 25),
                            child: Text(
                              "Money remaining: ${(int.tryParse(_variableValue)??0)- money_spent}",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: calculateRemainingMoneyColor()),
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
                child: CategoryWidget(
                    onCategorySelected: (String selectedCategory) {
                  setState(() {
                    sortCat = selectedCategory;
                  });
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
            Expanded(
              child: ExpenseShower(cat: sortCat, onExpenseDeleted: (){
                getTotalMoney(user!.uid);
              }),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: () {
            showBottomSheetDialog(context);
          },
          child: const Icon(Icons.add),
        ),
        drawer: Drawer(
          backgroundColor: Colors.cyan,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(.0),
                child: DrawerHeader(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user!.photoURL!),
                        radius: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text("${user?.displayName}"),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  leading: const Icon(Icons.attach_money),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.cyan,
                            title: const Text("Set Variable"),
                            content: TextField(
                              keyboardType: TextInputType.number,
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
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                    leading: const Icon(Icons.feedback_rounded),
                    title: const Text("Feedback"),
                    onTap: () =>
                        {submitFeedback(context), Navigator.of(context).pop()}),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Log Out"),
                  onTap: () {
                    Navigator.pop(context);
                    signOutUser();
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 15),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ListTile(
                      tileColor: Colors.red,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.0),
                              bottom: Radius.circular(20))),
                      leading: const Icon(Icons.delete_forever),
                      title: const Text("Delete All Data"),
                      onTap: () {
                        //userdata delete and all
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.red,
                                title: const Text("! WARNING !"),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Are you sure you want to delete all the data?",
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        deleteUserData(context);
                                      },
                                      child: const Text("Delete Anyway")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"))
                                ],
                              );
                            });
                      },
                    )),
              )
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
          isHTML: false));
    });
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
            color:Colors.cyan,
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
                    keyboardType: TextInputType.number,
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
                  onSave(context, textCont.text.trim(), selectedCategory,
                      user.uid);
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

    // Generate a unique identifier
    var uuid = const Uuid();
    String uniqueId = uuid.v4();

    // Create an index field by combining userId, category, and unique identifier
    String indexField = '$userId.$category.$uniqueId';

    try {
      await FirebaseFirestore.instance.collection('data').add({
        'money': money,
        'category': category,
        'userId': userId,
        'indexField': indexField,
        'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
      });
      Fluttertoast.showToast(
          msg: "Expense added successfully", toastLength: Toast.LENGTH_SHORT);

      Navigator.pop(context); // Close the bottom sheet
      getTotalMoney(userId);
      setState(() {
        sortCat = category;
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Failed to add expense: $e", toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> getTotalMoney(String uid) async {
    int totalMoney = 0;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('data')
          .where('userId', isEqualTo: uid)
          .get();

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int money = int.parse(data['money']); // Convert to integer
        totalMoney += money;
      });
      setState(() {
        money_spent = totalMoney;
      });
    } catch (e) {
      logger.e("There was an error retrieving the data: $e");
    }
  }
}
