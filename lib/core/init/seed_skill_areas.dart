import 'package:cloud_firestore/cloud_firestore.dart';

class SeedSkillAreas {
  static const _seedFlagDocId = '_seed';

  static Future<void> run({
    required FirebaseFirestore db,
    required String uid,
    required List<Map<String, String>> defaultAreas,
}) async {
    final userRef = db.collection('users').doc(uid);
    final seedRef = userRef.collection('meta').doc(_seedFlagDocId);
    final areasColl = userRef.collection('skillAreas');

      final seedSnap = await seedRef.get();
      final alreadySeeded = seedSnap.data()?['skillAreasSeeded'] == true;

      if (alreadySeeded) return;

      final batch = db.batch();

      for (final area in defaultAreas) {
        final key = area['key']!;
        final name = area['name']!;

        final ref = areasColl.doc(key);

        batch.set(
          ref,
          {
            'key': key,
          'name': name,
       'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'deletedAt': null,
        },
        SetOptions(merge:true),
        );
      }

      batch.set(seedRef, {
        'skillAreasSeeded': true,
        'seededAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    }
  }
