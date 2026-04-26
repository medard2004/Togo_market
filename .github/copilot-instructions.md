# Copilot instructions for Togo_market

This file gives Copilot-style agents the essential commands, architecture map, and repository-specific conventions.

1) Build, test, and lint (commands)

- Install deps: `flutter pub get`
- Run app (debug): `flutter run` (add `-d <device-id>` to choose device)
- Build APK/iOS: `flutter build apk --release` / `flutter build ios --release`
- Lint/analysis: `flutter analyze` / `flutter format --fix .`
- Code generation (Hive adapters, json serial):
  `flutter pub run build_runner build --delete-conflicting-outputs`
- Tests:
  - Full suite: `flutter test`
  - Coverage: `flutter test --coverage`
  - Single test file: `flutter test test/path/to/file_test.dart`
  - Run a single test by name: `flutter test --name "test name regex"`

2) High-level architecture (big picture)

- Flutter frontend only (mobile/web): organized by feature.
  - lib/screens/: feature screens
  - lib/widgets/: reusable UI
  - lib/controllers/: business logic using GetX (Get package)
  - lib/Api/: api_provider.dart + services/ (backend calls)
  - lib/models/: data models (some use Hive TypeAdapters)
  - lib/data/: mock data and fixtures
- State & navigation: GetX controllers manage app state and navigation.
- Persistence: Hive for local storage; Hive adapters generated with build_runner.
- Auth/backend: Firebase (firebase_core, firebase_auth) plus a Laravel backend (server-side schema in REFERENCE_PROJET.md).
- Assets: `.env` at repo root (loaded with flutter_dotenv) and assets/images/

3) Key conventions (repo-specific)

- Controllers named `*_controller.dart` live in lib/controllers/ and are singletons managed by Get.put() or Get.find().
- Services live under lib/Api/services/ and go through api_provider.dart for base URL/headers.
- Models using Hive require `@HiveType` annotations and a generated TypeAdapter; run build_runner after edits.
- Secrets/config: keep `.env` out of VCS; sample values may be in README or CI.
- Mock data: lib/data/mock_data.dart used for tests and stories—use it for quick component checks.
- Codegen: always run `build_runner` with `--delete-conflicting-outputs` when changing annotated models.
- Tests: place unit/widget tests under test/ mirroring lib/ structure; run a single file when iterating locally.

4) Where to look first

- lib/controllers/app_controller.dart — central app logic
- lib/Api/services/ — backend integrations (boutique_service.dart is important)
- lib/models/product_model.dart — representative data model
- REFERENCE_PROJET.md and CLAUDE.md — project rules and extra developer commands

5) AI assistant and other configs

- CLAUDE.md included with useful commands and architecture notes; consult it for deeper guidance.
- If adding other assistant configs, place them at repository root or .github and reference them here.

---

Created to help Copilot/assistant sessions start fast. Update when repo structure or build/test commands change.

6) Additional notes : Avant de repondre a mes questions et instruction, je veux que tu les reformule de maniere clair dans le jargon technique (peutetre parce que je les reformulerais mal) a ce que je puisse les comprendre
