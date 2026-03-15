import 'package:flutter/material.dart';
import 'package:progress_hub_2/features/skills/presentation/providers/skill_areas_provider.dart';
import 'skills_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_hub_2/core/widgets/tennis_ball_button.dart';

class SkillAreasScreen extends ConsumerStatefulWidget {
  const SkillAreasScreen({super.key});

  @override
  ConsumerState<SkillAreasScreen> createState() =>
      _SkillAreasScreenState();
}

class _SkillAreasScreenState extends ConsumerState<SkillAreasScreen> {

  //editing progress area name
  Future<void> _editItem(String id, String currentName) async {
    String updatedName = currentName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit name'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: currentName),
            decoration: const InputDecoration(hintText: 'Input new name'),
            onChanged: (value) => updatedName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (updatedName
                    .trim()
                    .isNotEmpty) {
                  Navigator.of(context).pop(updatedName);
                }
              },
              child: const Text('Renew'),
            ),
          ],
        );
      },
    ).then((result) async {
      if (result != null && result is String) {
        await ref.read(skillAreasControllerProvider).editArea(id, result);

      }
    });
  }

  Future<void> _showAddSkillDialog() async {
    String skillAreaName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // ignore: prefer_const_constructors
        return AlertDialog(
          title: const Text('Add new progress area'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Input progress area name',
            ),
            onChanged: (value) {
              skillAreaName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                if (skillAreaName
                    .trim()
                    .isNotEmpty) {
                  Navigator.of(context).pop(skillAreaName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name can\'t be empty')),
                  );

                }
              },
              child: const Text('Додати'),
            ),
          ],
        );
      },
    ).then((result) async {
      if (result != null && result is String) {
        await ref.read(skillAreasControllerProvider).addArea(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(skillAreasStreamProvider);
       // final skills = ref.watch(areasProvider);

     return  Scaffold(
       backgroundColor: Colors.transparent,
       body: areasAsync.when(
         loading: () => const Center(child: CircularProgressIndicator()),
         error: (e, _) => Center(child: Text('Error: $e')),
         data: (areas) => ListView.builder(
        itemCount: areas.length,
        itemBuilder: (context, index) {
          final area = areas[index];
          final areaId = area['id'] as String;
          final areaName = (area['name'] as String) ?? '';

          return ListTile(
            leading: const Icon(Icons.sports_tennis),
            title: Text(areaName, style:
              TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SkillsScreen(
                        areaId: areaId,
                        areaName: areaName,
                      ),
                ),
              );
            },
            // onLongPress: () =>
            //     _editItem(areaId, areaName),
            onLongPress: () async {
              final result = await showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(200, 200, 50, 50),
                  items: const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
              );
              if (!mounted) return;

              if (result == 'edit') {
                await _editItem(areaId, areaName);
              } else if (result == 'delete') {
                final ok = await showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete this skill group?'),
                      content: const Text('All related skills and goals will also be removed.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),),
                        TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Delete'),),
                      ],
                    ),
                );

                if (!mounted) return;

                if (ok == true) {
                  await ref.read(skillAreasControllerProvider).deleteArea(areaId);
                }
              }
            },
          );
        },
      ),
       ),
       floatingActionButton: TennisBallButton(
        onPressed: _showAddSkillDialog,
       ),
       );
  }
}