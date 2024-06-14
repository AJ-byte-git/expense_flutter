import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Method to set a variable
  Future<void> setVariable(String docId, String value) async {
    await _db.collection('variables').doc(docId).set({'value': value});
  }

  // Method to get a variable
  Future<String?> getVariable(String docId) async {
    DocumentSnapshot doc = await _db.collection('variables').doc(docId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['value'] as String?;
    }
    return null;
  }

  // Method to update a variable
  Future<void> updateVariable(String docId, String newValue) async {
    await _db.collection('variables').doc(docId).update({'value': newValue});
  }

  // Method to get a stream of a variable
  Stream<DocumentSnapshot> getVariableStream(String docId) {
    return _db.collection('variables').doc(docId).snapshots();
  }
}
