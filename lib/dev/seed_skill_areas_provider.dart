import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_hub_2/dev/seed_skill_areas.dart';
import 'package:progress_hub_2/data/default_skill_areas.dart';
import 'package:progress_hub_2/features/skills/presentation/providers/skill_areas_provider.dart';

final seedOnAppStartProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(firebaseFirestoreProvider);
  final uid = ref.watch(currentUserIdProvider);

  if (uid.isEmpty) return;

  await SeedSkillAreas.run(
      db: db,
      uid: uid,
      defaultAreas: defaultSkillAreas,
  );
});