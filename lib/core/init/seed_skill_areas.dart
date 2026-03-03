import 'package:cloud_firestore/cloud_firestore.dart';

class SeedSkillAreas {
  static const _seedFlagDocId = '_seed';
  
  static String _toDocId(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r's+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }

  static Future<void> run({
    required FirebaseFirestore db,
    required String uid,
    required List<String> defaultAreas,
}) async {
    final userRef = db.collection('users').doc(uid);
    final seedRef = userRef.collection('meta').doc(_seedFlagDocId);
    final areasColl = userRef.collection('skillAreas');

    await db.runTransaction((tx) async {
      final seedSnap = await tx.get(seedRef);

      final alreadySeeded = seedSnap.data()?['skillAreasSeeded'] == true;
      if (alreadySeeded) return;

      for (final raw in defaultAreas) {
        final areaName = raw.trim();
        if (areaName.isEmpty) continue;

        final docId = _toDocId(areaName);
        final areaRef = areasColl.doc(docId);

        final areaSnap = await tx.get(areaRef);
        final isNew = !areaSnap.exists;

        tx.set(areaRef, {
          'name': areaName,
          if (isNew) 'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'deletedAt': null,
        },
        SetOptions(merge:true),
        );
      }

      tx.set(seedRef, {
        'skillAreasSeeded': true,
        'seededAt': FieldValue.serverTimestamp(),
      });
    });
  }
}