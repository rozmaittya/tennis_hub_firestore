import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'skill_areas_provider.dart';

final skillsByAreaStreamProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, areaId) {

      final uid = ref.watch(currentUserIdProvider);
      final db = ref.watch(firebaseFirestoreProvider);

      return db
          .collection('users')
          .doc(uid)
          .collection('skills')
          .where('deletedAt', isNull: true)
          .where('areaId', isEqualTo: areaId)
          .where('isChecked', isEqualTo: false)
          .orderBy('name')
          .snapshots()
          .map((snap) => snap.docs
      .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
      .toList());
});

final skillsControllerProvider = Provider<SkillsController>((ref) {
  return SkillsController(ref);
});

class SkillsController {
  final Ref ref;
  SkillsController(this.ref);

  FirebaseFirestore get _db => ref.read(firebaseFirestoreProvider);
  String get _uid =>  ref.read(currentUserIdProvider);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('skills');

  Future<void> addSkill({required String areaId, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    await _col.add({
      'areaId': areaId,
      'name': trimmed,
      'isChecked': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'deletedAt': null,
    });
  }

  Future<void> editSkill({required String skillId, required String newName}) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    await _col.doc(skillId).update({
      'name': trimmed,
      'updateAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleSkill({required String skillId, required bool isChecked}) async {
    await _col.doc(skillId).update({
      'isChecked': isChecked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSkill(String skillId) async {
    await _col.doc(skillId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

