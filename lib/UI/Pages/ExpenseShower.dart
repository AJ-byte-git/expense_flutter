import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/UI/Utils/ExpenseTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpenseShower extends StatefulWidget {
  const ExpenseShower({super.key});

  @override
  State<ExpenseShower> createState() => _ExpenseShowerState();
}

class _ExpenseShowerState extends State<ExpenseShower> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      // Handle the case where the user is not authenticated
      return const Center(child: Text('User not authenticated'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data')
          .where('userId', isEqualTo: userId)
          .orderBy('cat')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data found'));
        }

        var documents = snapshot.data!.docs;
        return ListView.builder(
          itemBuilder: (context, index) {
            var data = documents[index].data() as Map<String, dynamic>;
            print('Document $index: $data');  // Debugging line
            return ExpenseTile(
              category: data['cat'],
              amount: data['money'],
            );
          },
          itemCount: documents.length,
        );
      },
    );
  }
}
