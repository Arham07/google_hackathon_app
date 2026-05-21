# BaKhabar Alerts — Developer Guide

This developer guide provides an overview of the BaKhabar Alerts Flutter application, detailing the codebase structure, navigation system, state management, and conventions used across feature modules.

---

## 📂 Directory Structure

The project follows a feature-first modular folder structure inside the `lib/` directory:

```
lib/
├── config/             # Global configurations (API, Map styling, assets)
├── core/               # Shared core services (Authentication, API client)
├── features/           # Modularized feature folders
│   ├── auth/           # Login & Signup flows
│   ├── home/           # Main shell container & navigation tabs
│   ├── incidents/      # Feed list, details view, priority filters, and state controller
│   ├── map/            # Google Map tab, custom markers, place search searchbar
│   ├── notifications/  # Notification center, custom route transitions, store
│   ├── onboarding/     # Onboarding carousel screens
│   ├── status/         # Analytics metrics and charts (SfCharts)
│   └── submit/         # Incident reporting forms and map-based pin picker
├── theme/              # Styling configs (colors, text styles, spacing, custom dark theme)
├── utils/              # Utility helpers (URL launcher, map icons helper)
├── widgets/            # Global reusable UI widgets (app logo, severity chips)
└── main.dart           # App entry point
```

---

## 🔄 State Management

The app uses the `Provider` package to handle reactive state propagation. The main controller is `IncidentsController` (`lib/features/incidents/incidents_controller.dart`).

### `IncidentsController` Role:
- Manages the active incident feed mode: `all`, `nearby`, or `priority`.
- Performs network requests via `EventsApi` to load incident records.
- Implements location permissions gates via `LocationService` for the `nearby` feed.
- Communicates UI-level navigation requests between widgets (e.g., coordinates a click on a feed card to fly the map camera to that coordinate via `requestMapFocus`).

### Usage Example:
```dart
// Reading incidents list in build method
final controller = context.watch<IncidentsController>();
final list = controller.visibleIncidents;

// Triggering state action (non-listening context)
context.read<IncidentsController>().setMode(IncidentListMode.nearby);
```

---

## 🧭 Navigation Hierarchy

The application features a single-shell navigation layout centered around `MainShell` (`lib/features/home/main_shell.dart`):

1. **Gate Resolution (`lib/app.dart`)**:
   - Checks if onboarding has been completed.
   - If not, routes to `OnboardingScreen`.
   - If completed, checks if the user is authenticated via `AuthService`.
   - Routes to `LoginScreen` or launches the `MainShell` respectively.
2. **Main Shell Tabs**:
   - **Tab 0 (Incidents)**: `IncidentsListScreen`
   - **Tab 1 (Map)**: `MapTabScreen`
   - **Tab 2 (Status)**: `StatusScreen`
   - **Tab 3 (Report)**: `SubmitIncidentScreen`

---

## 🎨 Styling and Theme System

The design system is managed globally under `lib/theme/`:
- **AppTheme**: Set to dark theme by default, styling `Material3` widgets, input decorations, and elevated buttons globally.
- **AppColors**: Defines color tokens (e.g., `AppColors.primary`, custom severity indicators like `priorityCritical`, and custom chart color mapping).
- **AppDimens**: ScreenUtil-responsive spacing, borders, icon sizes, and height/width parameters.
- **AppTextStyles**: Typography styles leveraging Google Fonts (`Outfit`).
