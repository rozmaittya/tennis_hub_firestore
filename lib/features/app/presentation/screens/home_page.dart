import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:progress_hub_2/core/init/seed_skill_areas_provider.dart';
import 'package:progress_hub_2/core/theme/gradient_background.dart';
import 'package:progress_hub_2/features/app/presentation/providers/current_screen_provider.dart';
import 'package:progress_hub_2/features/goals/presentation/screens/goals_screen.dart';
import 'package:progress_hub_2/features/app/presentation/models/screen_data.dart';
import 'package:progress_hub_2/features/skills/presentation/screens/skill_areas_screen.dart';
import 'package:progress_hub_2/features/skills/presentation/screens/mastered_skills_screen.dart';
import 'package:progress_hub_2/features/app/presentation/screens/home_content_screen.dart';
import 'package:progress_hub_2/core/widgets/help_dialog.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seedState = ref.watch(seedOnAppStartProvider);

    seedState.whenOrNull(
      error: (error, stackTrace) {
        debugPrint('Seed error: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    final currentScreen = ref.watch(currentScreenProvider);

    return GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leadingWidth: 36,
            titleSpacing: 8,

            backgroundColor: Colors.transparent,
            title: Text(currentScreen.title, style: const TextStyle(
              fontSize: 16,
            ),),
            leading: IconButton(
                onPressed: () {
                  ref.read(currentScreenProvider.notifier).state = ScreenData(
                      title: 'Tennis Hub',
                      screen: const HomeContentScreen(),
                  );
                  },
                icon: Icon(Icons.home),
                visualDensity: VisualDensity.compact,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.spoke),
                tooltip: 'Progress areas/Tennis skills',
                onPressed: () {
                  ref.read(currentScreenProvider.notifier).state = ScreenData(
                      title: 'Skills',
                      screen: const SkillAreasScreen(),
                  );
                  },
                  ),
              IconButton(
                icon: Icon(Icons.task_alt),
                tooltip: 'game/training goals',
                onPressed: () {
                  ref.read(currentScreenProvider.notifier).state = ScreenData(
                      title: 'Game goals',
                      screen: const GoalsScreen(),
                  );
                }, ),
              IconButton(
                  tooltip: 'Mastered skills',
                  onPressed: () {
                    ref.read(currentScreenProvider.notifier).state = ScreenData(
                        title: 'Mastered skills',
                        screen: const MasteredSkillsScreen(),
                    );
              },
                  icon: Icon(Icons.accessibility_new)),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'How it works',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const HelpDialog(),
                  );
                },
              ),

            ],
          ),
          body: currentScreen.screen,

        ),
    );
  }
}