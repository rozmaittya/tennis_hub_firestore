import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../providers/mastered_skills_provider.dart';
import '../providers/skill_areas_map_provider.dart';
import '../providers/skills_provider.dart';

class MasteredSkillsScreen extends ConsumerWidget {
  const MasteredSkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteredSkillsAsync = ref.watch(masteredSkillsStreamProvider);
    final areasMapAsync = ref.watch(skillAreasMapProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: masteredSkillsAsync.when(
          error: (e, _) => Center(child: Text('Errot: $e'),),
          loading: () => const Center(child: CircularProgressIndicator(),),
          data: (masteredSkills) {
            final areasMap = areasMapAsync.value ?? const <String, String>{};

            return ListView.builder(
              itemCount: masteredSkills.length,
              itemBuilder: (context, index) {
                final masteredSkill = masteredSkills[index];
                final skillId = masteredSkill['id'] as String;
                final skillName = (masteredSkill['name'] as String) ?? '';
                final areaId = (masteredSkill['areaId'] as String) ?? '';
                final areaName = areasMap[areaId] ?? 'Unknown area';

                return ListTile(
                  title: Text(
                    areaName,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  subtitle: Text(
                    skillName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Checkbox(
                    value: true,
                    onChanged: (bool? value) async {
                      if (value == null) return;

                      if (value == false) {
                        final ok = await showDialog(
                          context: context,
                          builder: (_) =>
                              AlertDialog(
                                title: const Text('Mark as not mastered?'),
                                content: const Text(
                                  'Are you sure you want to mark this skill as not mastered and continue to walk on it?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Yes, mark'),
                                  ),
                                ],
                              ),
                        );

                        if (!context.mounted || ok != true) return;

                        await ref.read(skillsControllerProvider).toggleSkill(
                          skillId: skillId,
                          isChecked: false,
                        );
                      }
                    },
                  ),
                );
              },
            );
          }),
    );
  }
}
