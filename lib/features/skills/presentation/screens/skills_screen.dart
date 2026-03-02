import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_hub_2/features/goals/presentation/providers/goals_firestore_provider.dart';
import '../../../../providers/mastered_screens_providers.dart';
import '../../../../core/widgets/tennis_ball_button.dart';
import '../../../../core/theme/gradient_background.dart';
import '../providers/skills_provider.dart';

class SkillsScreen extends ConsumerStatefulWidget {
  final String areaId;
  final String areaName;

  const SkillsScreen({
    super.key,
    required this.areaId,
    required this.areaName,
  });

  @override
  ConsumerState<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends ConsumerState<SkillsScreen> {
  int get _areaIdInt  => int.tryParse(widget.areaId) ?? -1;

  Future<void> _toggleSkill(String id, bool isChecked) async {
    await ref
        .read(skillsControllerProvider)
        .toggleSkill(
        skillId: id,
        isChecked: isChecked,
    );
  }

  Future<void> _editSkill(String id, String currentName) async {
    String updatedName = currentName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit skill'),
        content: TextField(
          autofocus: true,
          controller: TextEditingController(text: currentName),
          decoration: const InputDecoration(hintText: 'Input new skill name'),
          onChanged: (value) => updatedName = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
          ),
          TextButton(onPressed: () {
            if (updatedName.trim().isNotEmpty) {
              Navigator.of(context).pop(updatedName);
            }
          },
              child: const Text('Save'),
          ),
        ],
      )
    ).then((result) async {
      if (result != null && result is String) {
        await ref.read(skillsControllerProvider).editSkill(
            skillId: id,
            newName: result,
        );
      }
    });
  }

  Future<void> _showAddSkillDialog() async {
    String skillName = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add new skill'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Input new skill name'),
            onChanged: (value) => skillName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (skillName.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(skillName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name should be not empty')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result != null) {
      await ref.read(skillsControllerProvider).addSkill(
        areaId: widget.areaId,
        name: result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final skillsAsync = ref.watch(skillsByAreaStreamProvider(widget.areaId));

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            widget.areaName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        body:  skillsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (skills) => ListView.builder(
          itemCount: skills.length,
          itemBuilder: (itemContext, index) {
            final skill = skills[index];
            final skillId = skill['id'] as String;
            final name = (skill['name'] as String?) ?? '';
            final isChecked = (skill['isChecked'] as bool?) ?? false;

            return ListTile(
              title: Text(
                name,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(0.5, 0.5),
                      blurRadius: 1.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              trailing: Checkbox(
                value: isChecked,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  if (value == true) {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Mark as learned?'),
                        content: const Text(
                          'Do you really want to mark this skill as fully automated?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Yes, mastered'),
                          ),
                        ],
                      ),
                    );

                    if (!mounted || ok != true) return;
                  }

                  await _toggleSkill(skillId, value);
                  ref.invalidate(masteredSkillsProvider);
                },
              ),
              onLongPress: () async {
                final result = await showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(200, 200, 50, 50),
                  items: const [
                    PopupMenuItem(value: 'addToGoals', child: Text('Add to goals')),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                );

                if (!mounted) return;

                if (result == 'edit') {
                  await _editSkill(skillId, name);
                  if (!mounted) return;
                } else if (result == 'delete') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete skill?'),
                      content: const Text(
                        'Are you sure you want to delete this skill?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (!mounted) return;

                  if (ok == true) {
                    await ref.read(skillsControllerProvider).deleteSkill(skillId);
                  }
                } else if (result == 'addToGoals') {
                    ref.read(goalsControllerProvider).addGoal(skillId);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goal added'))
                    );
                }
              },
            );
          },
          ),
        ),
        floatingActionButton: TennisBallButton(onPressed: _showAddSkillDialog),
        ),
    );
  }
}
