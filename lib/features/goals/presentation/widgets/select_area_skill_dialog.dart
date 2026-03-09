import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:progress_hub_2/features/skills/presentation/providers/skills_map_provider.dart';
import 'package:progress_hub_2/features/skills/presentation/providers/skill_areas_map_provider.dart';

class SelectAreaSkillDialog extends ConsumerStatefulWidget {
  final String? selectedSkillId;
  const SelectAreaSkillDialog({super.key, this.selectedSkillId});

  @override
  ConsumerState<SelectAreaSkillDialog> createState() => _SelectAreaSkillDialogState();
}

class _SelectAreaSkillDialogState extends ConsumerState<SelectAreaSkillDialog> {
  String? selectedAreaId;
  String? selectedSkillId;

  @override
  void initState() {
    super.initState();
    selectedSkillId = widget.selectedSkillId;
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync =  ref.watch(skillAreasMapProvider);
    final skillsAsync = ref.watch(skillsMapProvider);

    if (areasAsync.isLoading || skillsAsync.isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 120,
            child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (areasAsync.hasError || skillsAsync.hasError) {
      return AlertDialog(
        content: Text('Error loading data'),
      );
    }

    final areasMap = areasAsync.value ?? <String, String>{};
    final skillsMap = skillsAsync.value ?? {};

    final areas = areasMap.entries.map((e) => {'id': e.key, 'name': e.value}).toList()
    ..sort((a,b) => (a['name'] as String).compareTo(b['name'] as String));

    if (selectedAreaId == null && selectedSkillId != null) {
      final s = skillsMap[selectedSkillId!];
      final aId = s?['areaId'] as String?;
      if (aId != null)  selectedAreaId = aId;
    }

    final skills = skillsMap.entries
    .map((e) => {'id': e.key, ...e.value})
    .where((s) {
      if (selectedAreaId == null) return false;
      final areaId = s['areaId'] as String?;
      final deletedAt = s['deletedAt'];
      final isChecked = (s['isChecked'] as bool?) ?? false;

      return areaId == selectedAreaId &&
      deletedAt == null &&
      isChecked == false;
    })
    .toList()
    ..sort((a, b) {
      final aName = (a['name'] as String? ?? '');
      final bName = (b['name'] as String? ?? '');
      return aName.compareTo(bName);
    });

    return AlertDialog(
      title: const Text('Select goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: selectedAreaId,
            decoration: const InputDecoration(labelText: 'Skill area'),
            items: areas
              .map((a) => DropdownMenuItem<String>(
                value: a['id'] as String,
                child: Text(a['name'] as String),
              ))
          .toList(),
          onChanged: (areaId) {
            setState(() {
              selectedAreaId = areaId;
              selectedSkillId = null;
            });
          },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: selectedSkillId,
        decoration: const InputDecoration(labelText: 'Skill'),
        items: skills
            .map((s) => DropdownMenuItem<String>(
            value: s['id'] as String,
            child: Text((s['name'] as String?) ?? ''),
          ))
          .toList(),
          onChanged: (skillId) {
          setState(() => selectedSkillId = skillId);
          },
      ),
     ],
    ),
    actions: [
      TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
      ),
      TextButton(
          onPressed: () {
            if (selectedSkillId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar( content: Text('Please select skill'))
              );
              return;
            }
            Navigator.pop(context, selectedSkillId);
          },
          child: const Text('Save'),
      ),
    ],);
  }
}