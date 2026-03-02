import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'skill_areas_provider.dart';

final skillAreasMapProvider =
    Provider.autoDispose<AsyncValue<Map<String, dynamic>>>((ref) {
      final areasAsync = ref.watch(skillAreasStreamProvider);

      return areasAsync.whenData((areas) {
        final map = <String, String>{};
        for (final a in areas) {
          final id = a['id'] as String;
          final name = (a['name'] as String) ?? '';
          map[id] = name;
        }
        return map;
      });
    });

final skillAreaNameToIdMapProvider = Provider<Map<String, String>>((ref) {
  final areasMap = ref.watch(skillAreasMapProvider).value ?? <String, String>{};

  return {
    for (final e in areasMap.entries) e.value: e.key,
  };
});

final areaIdByNameProvider = Provider.family<String?, String>((ref, areaName) {
  final nameToId = ref.watch(skillAreaNameToIdMapProvider);
  return nameToId[areaName];
});