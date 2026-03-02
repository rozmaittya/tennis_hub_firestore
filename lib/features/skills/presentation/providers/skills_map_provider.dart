import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:progress_hub_2/features/skills/presentation/providers/skill_areas_provider.dart';

final skillsStreamProvider = 
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final uid = ref.watch(currentUserIdProvider);
      final db = ref.watch(firebaseFirestoreProvider);
      
      return db
          .collection('users')
          .doc(uid)
          .collection('skills')
          .where('deletedAt', isNull: true)
          .snapshots()
          .map((snap) => snap.docs
      .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
          .toList());
    });

final skillsMapProvider =
    Provider.autoDispose<AsyncValue<Map<String, Map<String, dynamic>>>>((ref) {
      final skillsAsync = ref.watch(skillsStreamProvider);

      return skillsAsync.whenData((skills) {
        return {
          for (final s in skills)
            s['id'] as String: s
        };
      });
    });