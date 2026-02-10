import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_project/models/cv_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateCV(String uid, CVModel cv) async {
    await _db.collection('cvs').doc(uid).set(cv.toMap());
  }

  Stream<CVModel?> streamCV(String uid) {
    return _db.collection('cvs').doc(uid).snapshots().map((snap) {
      if (snap.exists && snap.data() != null) {
        return CVModel.fromMap(snap.data()!, snap.id);
      }
      return null;
    });
  }
}
