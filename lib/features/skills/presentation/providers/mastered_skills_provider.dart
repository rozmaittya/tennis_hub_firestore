import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:progress_hub_2/core/providers/app_providers.dart';

final masteredSkillsStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>> ((ref) {
  final uid = ref.watch(currentUserIdProvider);
  final db = ref.watch(firebaseFirestoreProvider);

  return db
      .collection('users')
      .doc(uid)
      .collection('skills')
      .where('isChecked', isEqualTo: true)
      .where('deletedAt', isNull: true)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
  .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
  .toList());
});