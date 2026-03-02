import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:progress_hub_2/features/goals/presentation/providers/goals_firestore_provider.dart';
import 'package:progress_hub_2/features/skills/presentation/providers/skill_areas_map_provider.dart';
import 'package:progress_hub_2/features/skills/presentation/providers/skills_map_provider.dart';
import 'package:progress_hub_2/features/goals/presentation/widgets/select_area_skill_dialog.dart';

import '../widgets/tennis_ball_button.dart';
import '../utils/show_context_menu.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}
 class _GoalsScreenState extends ConsumerState<GoalsScreen> {

  Offset _tapPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsStreamProvider);
    final skillsMap = ref.watch(skillsMapProvider).value ?? {};
    final areasMap = ref.watch(skillAreasMapProvider).value ?? {};

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) => ListView.builder(
        itemCount: goals.length,
        itemBuilder: (itemContext, index) {
          final goal = goals[index];

          final goalId = goal['id'] as String;
          final skillId = goal['skillId'] as String;

          final skill = skillsMap[skillId];
          final skillName = (skill?['name'] as String?) ?? '';
          final areaId = (skill?['areaId'] as String?) ?? '';
          final areaName = areasMap[areaId] ?? '';

          return GestureDetector(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // left accent line
                  Container(
                    width: 6,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text(
                        areaName,
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          skillName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                     // trailing: const Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
            ),

            onTapDown: (details) {
              _tapPosition = details.globalPosition;
            },
            onLongPress: () async {
              final selected = await showContextMenu(
                context: context,
                tapPosition: _tapPosition,
                items: const [
                  PopupMenuItem(value: 'edit', child: Text('edit')),
                  PopupMenuItem(value: 'delete', child: Text('delete')),
                ],
              );

              if (!context.mounted || selected == null) return;

              switch (selected) {
                case 'edit':
                  final newSkillId = await showDialog<String>(
                    context: context,
                    builder: (_) => SelectAreaSkillDialog(selectedSkillId: skillId),
                  );
                  if (!context.mounted || newSkillId == null) return;

                  await ref.read(goalsControllerProvider).editGoal(
                      goalId: goalId,
                      newSkillId: newSkillId);
                  break;

                case 'delete':
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete goal?'),
                      content: const Text('Are you sure you want to delete this goal?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete'))
                      ],
                    ),
                  );

                  if (!context.mounted) return;

                  if (ok == true) {
                    await ref.read(goalsControllerProvider).deleteGoal(goalId);
                  }
                  break;
              }
            },
          );
        },
      ),
      ),
      floatingActionButton: TennisBallButton(
        onPressed: () async {
          final skillId = await showDialog<String>(
            context: context,
            builder: (_) => const SelectAreaSkillDialog(),
          );
          if (skillId != null) {
            await ref.read(goalsControllerProvider).addGoal(skillId);
          }
        },
      ),
    );
  }
}
