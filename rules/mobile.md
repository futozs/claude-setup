---
paths:
  - "**/*.swift"
  - "**/*.kt"
  - "**/*.kts"
  - "**/*.dart"
  - "**/pubspec.yaml"
---
# Mobile (Swift / Kotlin / Flutter)

- Swift: SwiftUI + Swift Concurrency (`async/await`, actors, `@MainActor` for UI state); value types by default; no force unwraps outside tests. Build and run in the iOS Simulator to verify UI changes.
- Kotlin/Android: Jetpack Compose, coroutines + Flow with structured concurrency (`viewModelScope`, no `GlobalScope`), immutable UI state from the ViewModel, Gradle version catalog if present.
- Flutter/Dart: `dart analyze` and `flutter test` clean before done; `const` constructors where possible; keep business logic out of widgets; follow the project's existing state management, don't introduce a new one.
- Respect platform conventions (HIG / Material) over web habits: native navigation, safe areas, dynamic type / font scaling, 44pt / 48dp touch targets.
