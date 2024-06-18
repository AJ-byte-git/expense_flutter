import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/UI/Utils/ExpenseTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';

class ExpenseShower extends StatefulWidget {
  final String cat;

  const ExpenseShower({super.key, required this.cat});

  @override
  State<ExpenseShower> createState() => _ExpenseShowerState();
}

class _ExpenseShowerState extends State<ExpenseShower> {
  Future<QuerySnapshot> _fetchExpenses(String userId, String cat) {
    if (cat == "General") {
      return FirebaseFirestore.instance
          .collection('data')
          .where('userId', isEqualTo: userId)
          .get();
    } else {
      return FirebaseFirestore.instance
          .collection('data')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: cat)
          .get();
    }
  }

  Future<void> _deleteExpense(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('data').doc(docId).delete();
      Logger().i("Expense with ID: $docId deleted successfully");
    } catch (e) {
      Logger().e("Error deleting expense: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final logger = Logger();

    if (userId == null) {
      // Handle the case where the user is not authenticated
      return const Center(child: Text('User not authenticated'));
    }

    return FutureBuilder<QuerySnapshot>(
      future: _fetchExpenses(userId, widget.cat),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          logger.e("${snapshot.error}");
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Enter your expense'));
        }

        var documents = snapshot.data!.docs;
        return ListView.builder(
          itemBuilder: (context, index) {
            var data = documents[index].data() as Map<String, dynamic>;
            var docId = documents[index].id;
            logger.d("expense: $index: $data");

            return Slidable(
              key: Key(docId),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    borderRadius: BorderRadius.circular(10),
                    onPressed: (context) {
                      _deleteExpense(docId);
                      setState(() {
                        documents.removeAt(index);
                      });
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 5), // Adjusted padding
                  ),
                ],
              ),
              child: ExpenseTile(
                category: data['category'],
                amount: data['money'],
              ),
            );
          },
          itemCount: documents.length,
        );
      },
    );
  }
}
