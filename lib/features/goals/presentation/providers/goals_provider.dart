import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:progress_hub_2/core/providers/app_providers.dart';

final goalsStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final uid = ref.watch(currentUserIdProvider);
      final db = ref.watch(firebaseFirestoreProvider);

      return db
          .collection('users')
          .doc(uid)
          .collection('goals')
          .where('deletedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
              .toList());
    });

final goalsControllerProvider = Provider<GoalsController>((ref) {
  return GoalsController(ref);
});

class GoalsController {
  final Ref ref;
  GoalsController(this.ref);

  FirebaseFirestore get _db => ref.read(firebaseFirestoreProvider);
  String get _uid => ref.read(currentUserIdProvider);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('goals');
  
  Future<void> addGoal(String skillId) async {
    final existing = await _col
        .where('deletedAt', isNull: true)
        .where('skillId', isEqualTo: skillId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _col.add({
      'skillId': skillId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'deletedAt': null,
    });
  }

  Future<void> deleteGoal(String goalId) async {
    await _col.doc(goalId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editGoal({
    required String goalId,
    required String newSkillId,
}) async {
    final existing = await _col
        .where('deletedAt', isNull: true)
        .where('skillId', isEqualTo: newSkillId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _col.doc(goalId).update({
      'skillId': newSkillId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}