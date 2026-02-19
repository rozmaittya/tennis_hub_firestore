import 'package:flutter/material.dart';
import 'package:progress_hub_2/providers/goals_providers.dart';
import '../features/skills/presentation/providers/skill_areas_provider.dart';
import '../screens/skills_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/tennis_ball_button.dart';
import '../providers/mastered_screens_providers.dart';
import '../database/db_constants.dart';

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

        ref.invalidate(masteredSkillsProvider);
        ref.invalidate(goalsProvider);
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
            onLongPress: () =>
                _editItem(areaId, areaName),
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