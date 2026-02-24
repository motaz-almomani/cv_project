import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_project/models/cv_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addCV(CVModel cv) async {
    await _db.collection('cvs').add(cv.toMap());
  }

  Future<void> updateCV(String docId, CVModel cv) async {
    await _db.collection('cvs').doc(docId).update(cv.toMap());
  }

  Future<void> deleteCV(String docId) async {
    await _db.collection('cvs').doc(docId).delete();
  }

  Stream<List<CVModel>> streamUserCVs(String uid) {
    return _db
        .collection('cvs')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => CVModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
