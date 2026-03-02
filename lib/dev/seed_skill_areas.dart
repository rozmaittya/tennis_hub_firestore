import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class SeedSkillAreas {
  static const _seedFlagDocId = '_seed';

  static Future<void> run({
    required FirebaseFirestore db,
    required String uid,
    required List<String> defaultAreas,
}) async {
    final userRef = db.collection('users').doc(uid);

    final seedRef = userRef.collection('meta').doc(_seedFlagDocId);

    await db.runTransaction((tx) async {
      final seedSnap = await tx.get(seedRef);

      final alreadySeeded = seedSnap.data()?['skillAreasSeeded'] == true;
      if (alreadySeeded) return;

      final areasColl = userRef.collection('skillAreas');

      for (final areaName in defaultAreas) {
        final areaDocRef = await areasColl.doc();
        tx.set(areaDocRef, {
          'name': areaName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'deletedAt': null,
        });
      }

      tx.set(seedRef, {
        'skillAreasSeeded': true,
        'seededAt': FieldValue.serverTimestamp(),
      });
    });
  }
}