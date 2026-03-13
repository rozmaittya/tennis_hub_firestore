# Tennis Hub 🎾
<p align="center">
  <img src="screenshots/preview.png" alt="Tennis Hub App Preview" width="300">
</p>

Tennis Hub is a Flutter mobile app designed to help tennis players
track skill development, manage training goals, and stay motivated
with daily improvement tips.

The app demonstrates clean Flutter architecture, сloud data storage,
and scalable state management — suitable for real-world sports and
lifestyle applications.

---

## 📱 App Screenshots

<!-- Screenshots -->
### Home & Guidance
<img src="screenshots/tip_of_day.png" width="230" />
<img src="screenshots/help.png" width="230" />

### Skills & Areas
<img src="screenshots/skill_areas.png" width="230" />
<img src="screenshots/skills.png" width="230" />

### Goals & Progress
<img src="screenshots/goals.png" width="230" />
<img src="screenshots/mastered_skills.png" width="230" />


---


## 🚀 Key Features

- Skills organized into groups with progress tracking
- Training and match goals
- "Tip of the Day" to encourage consistent improvement
- Cloud data storage using Firebase Firestore
- Clean separation of UI, state, and data layers

---

## 🧠 Technical Highlights

- Riverpod for predictable and testable state management
- Firebase Firestore backend
- Repository pattern for data access abstraction
- Modular and scalable folder structure
- Null-safe Dart codebase

---

## 🛠 Tech Stack

- Flutter (Material 3)
- Riverpod
- Firebase Firestore

---

## 🧩 Architecture Overview

```text
lib/
├─ core/
│  ├─ config/
│  │  └─ firebase_options.dart
│  ├─ init/
│  │  ├─ seed_skill_areas.dart
│  │  └─ seed_skill_areas_provider.dart
│  ├─ providers/
│  │  └─ app_providers.dart
│  ├─ theme/
│  │  └─ gradient_background.dart
│  └─ widgets/
│     ├─ help_dialog.dart
│     ├─ show_context_menu.dart
│     └─ tennis_ball_button.dart
│
├─ data/
│  └─ default_skill_areas.dart
│
├─ features/
│  ├─ app/
│  │  └─ presentation/
│  │     ├─ models/
│  │     │  └─ screen_data.dart
│  │     ├─ providers/
│  │     │  └─ current_screen_provider.dart
│  │     └─ screens/
│  │        ├─ home_content_screen.dart
│  │        └─ home_page.dart
│  │
│  ├─ goals/
│  │  └─ presentation/
│  │     ├─ providers/
│  │     │  └─ goals_provider.dart
│  │     ├─ screens/
│  │     │  └─ goals_screen.dart
│  │     └─ widgets/
│  │        └─ select_area_skill_dialog.dart
│  │
│  ├─ skills/
│  │  └─ presentation/
│  │     ├─ providers/
│  │     │  ├─ mastered_skills_provider.dart
│  │     │  ├─ skill_areas_map_provider.dart
│  │     │  ├─ skill_areas_provider.dart
│  │     │  ├─ skills_map_provider.dart
│  │     │  └─ skills_provider.dart
│  │     └─ screens/
│  │        ├─ mastered_skills_screen.dart
│  │        ├─ skill_areas_screen.dart
│  │        └─ skills_screen.dart
│  │
│  └─ tips/
│     ├─ data/
│     │  └─ random_tennis_tips.dart
│     └─ providers/
│        └─ tips_provider.dart
│
└─ main.dart