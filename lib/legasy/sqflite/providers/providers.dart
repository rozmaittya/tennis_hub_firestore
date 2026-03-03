import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/app/presentation/models/screen_data.dart';
import '../../../features/app/presentation/screens/home_content_screen.dart';


final currentScreenProvider = StateProvider<ScreenData>((ref) {
  return ScreenData(
    title: 'Tennis Hub',
    screen: const HomeContentScreen(),
        );
});