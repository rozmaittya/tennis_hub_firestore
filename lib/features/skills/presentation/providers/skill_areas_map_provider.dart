import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'skill_areas_provider.dart';

final skillAreasMapProvider =
    Provider.autoDispose<AsyncValue<Map<String, String>>>((ref) {

      final areasAsync = ref.watch(skillAreasStreamProvider);

      return areasAsync.whenData((areas) {
        return {
          for (final a in areas)
            (a['id'] as String): ((a['name'] as String?) ?? ''),
        };
      });
    });

final skillAreaNameToIdMapProvider = Provider.autoDispose<Map<String, String>>((ref) {
  final areasMap = ref.watch(skillAreasMapProvider).value ?? <String, String>{};

  return {
    for (final e in areasMap.entries) e.value: e.key,
  };
});

final areaIdByNameProvider = Provider.family.autoDispose<String?, String>((ref, areaName) {
  final nameToId = ref.watch(skillAreaNameToIdMapProvider);
  return nameToId[areaName];
});

final  skillAreaIdByKeyMapProvider =
    Provider.autoDispose<Map<String, String>>((ref) {
      final areasMap = ref.watch(skillAreasStreamProvider);

      return areasMap.when(
          data: (areas) {
            return {
              for (final a in areas)
                if (a['key'] != null && a['id'] != null)
                  a['key'] as String: a['id'] as String,
            };
          },
          error: (_, __) => <String, String>{},
          loading: () => <String, String>{},
      );
    });

final areaIdByKeyProvider =
    Provider.family.autoDispose<String?, String>((ref, areaKey) {
      final keyToId = ref.watch(skillAreaIdByKeyMapProvider);
      return keyToId[areaKey];
    });