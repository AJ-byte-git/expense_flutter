import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/UI/Utils/ExpenseTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ExpenseShower extends StatefulWidget {
  final String cat;
  const ExpenseShower({super.key, required this.cat});

  @override
  State<ExpenseShower> createState() => _ExpenseShowerState();
}

class _ExpenseShowerState extends State<ExpenseShower> {
  Future<QuerySnapshot> _fetchExpenses(String userId, String cat) {
    return FirebaseFirestore.instance
        .collection('data')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: cat)
        .get();
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
      future: _fetchExpenses(userId, widget.cat), // Use widget.cat here
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
            logger.d("expense: $index: $data"); // Debugging line
            return ExpenseTile(
              category: data['category'],
              amount: data['money'],
            );
          },
          itemCount: documents.length,
        );
      },
    );
  }
}
