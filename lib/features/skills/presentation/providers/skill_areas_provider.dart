import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserIdProvider = Provider<String>((ref) => 'demo');

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final skillAreasStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final uid = ref.watch(currentUserIdProvider);
      final db = ref.watch(firebaseFirestoreProvider);

      return db
          .collection('users')
          .doc(uid)
          .collection('skillAreas')
          .orderBy('name')
          .snapshots()
          .map((snap) => snap.docs
      .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
          .toList());
    });

final skillAreasControllerProvider = Provider<SkillAreasController>((ref) {
  return SkillAreasController(ref);
});

class SkillAreasController {
  final Ref ref;
  SkillAreasController(this.ref);

  FirebaseFirestore get _db => ref.read(firebaseFirestoreProvider);
  String get _uid => ref.read(currentUserIdProvider);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('skillAreas');

  Future<void> addArea(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    await _col.add({
      'name': trimmed,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
      'deleteAt': null,
    });
  }

  Future<void> editArea(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    await _col.doc(id).update({
      'name': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

}

