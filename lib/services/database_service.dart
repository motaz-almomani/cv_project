import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_project/models/cv_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addCV(CVModel cv) async {
    final map = cv.toMap();
    map['createdAt'] = FieldValue.serverTimestamp();
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('cvs').add(map);
  }

  Future<void> updateCV(String docId, CVModel cv) async {
    final map = cv.toMap();
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('cvs').doc(docId).update(map);
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
      final list = snap.docs.map((doc) => CVModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) {
        final t = b.updatedAtMs.compareTo(a.updatedAtMs);
        if (t != 0) return t;
        return b.createdAtMs.compareTo(a.createdAtMs);
      });
      return list;
    });
  }
}
