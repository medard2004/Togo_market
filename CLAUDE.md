# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

- Build and run Flutter app:
  ```bash
  flutter run
  flutter build apk --release
  flutter build ios --release
  ```
- Linting and static analysis:
  ```bash
  flutter analyze
  flutter format --fix .
  ```
- Testing:
  ```bash
  flutter test
  flutter test test/ --coverage
  ```
- Dependency management:
  ```bash
  flutter pub get
  flutter pub upgrade --major-versions
  ```

## Architecture Overview

- Frontend: Flutter application organized by features/screens
  - lib/screens/: Contains UI screens grouped by feature (auth, home, product, seller, etc.)
  - lib/widgets/: Reusable widgets
  - lib/controllers/: Business logic controllers (boutique_controller.dart, app_controller.dart)
  - lib/models/: Data models matching backend schema
  - lib/Api/: API client and services (api_provider.dart, services/*)
  - lib/data/: Mock data and utilities

- Backend/Database: Referenced in REFERENCE_PROJET.md for business rules
  - Uses Laravel backend with specific database schema:
    - Users, boutiques, categories, products, images_produit, commandes, lignes_commande, conversations, messages, favoris, notifications, villes, quartiers, adresses, category_user
    - Product lifecycle states: actif/reserve/vendu
    - Payment handled via cash or mobile transfer (TMoney/Flooz) with screenshot validation
    - Orders tied to single seller, no cart merging

- State Management:
  - Uses Get package for navigation and rudimentary state management
  - Controllers in lib/controllers/ handle business logic per domain

- Persistence:
  - Hive for local storage
  - Firebase Auth for authentication options
  - firebase_core for backend integration

- Testing:
  - Unit/widget tests in test/ directory
  - Mock data in lib/data/mock_data.dart for test fixtures

## Key Files to Reference

- lib/Api/services/boutique_service.dart - business logic for seller operations
- lib/models/product_model.dart - product data model reflecting REFERENCE_PROJET.md schema
- lib/controllers/app_controller.dart - main application controller
- REFERENCE_PROJET.md - detailed business rules and database schema
- lib/data/mock_data.dart - test data definitions