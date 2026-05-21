# BaKhabar Alerts — QA & Testing Guide

This guide outlines the automated test suite configurations, mocking strategies, and manual quality assurance checklists for verifying the stability of the BaKhabar Alerts client.

---

## 🤖 Automated Testing

### 1. Test Suite Commands
To run the complete automated test suite locally, run:
```bash
flutter test
```

### 2. Network Mocking Strategy (Dio Integration)
The client tests verify API behavior by replacing the default Dio network adapter with a mock `HttpClientAdapter`:
- **`_JsonAdapter`**: Intercepts HTTP connections and returns predefined JSON strings with specific HTTP status codes (e.g., simulating a successful `200` with mock payload vs a `500` server database exception).
- **Assertion**: Verifies that standard error bodies map correctly to user-friendly `ApiException` instances to avoid app crashes.

### 3. Widget & Gate Testing
- **SharedPreferences Mocking**: In `widget_test.dart`, initial onboarding/login flags are mocked.
- **Assertion**: Verifies that when first loading the application with fresh storage values, the user is properly routed to the onboarding instructions carousel showing "Pakistan needs you prepared".

---

## 📋 Manual QA Checklist

### 1. Authentication & Onboarding
- [ ] **First Launch**: Open the app from a clean install; confirm the onboarding screen is shown.
- [ ] **Onboarding Carousel**: Verify swipe gestures work and the button label changes from "Next" to "Get started" on the final slide.
- [ ] **Gate Transitions**: Verify tapping "Skip" or "Get started" successfully saves onboarding completion state and forwards user to the Login screen.
- [ ] **Auth Persistent Gate**: Verify that after logging in once, restarting the app opens directly to the Incidents home shell.

### 2. Incident List Feed
- [ ] **Category Chips**: Toggle severity filters (Critical, High, Medium, Low) and confirm cards dynamically hide/show.
- [ ] **GPS Switch**: Switch to "Nearby" mode; confirm permission dialog is requested.
- [ ] **Empty State**: Verify appropriate empty status illustrations appear if all severity filters are toggled off.

### 3. Interactive Map Tab
- [ ] **Location Sync**: Tap the "My Location" Floating Action Button; verify camera moves to user location.
- [ ] **Show All Alerts**: Tap the "Show all alerts" button; verify camera fits all active marker coordinates inside the viewport bounds.
- [ ] **Marker Interaction**: Tap a marker; verify map centers on coordinates and the `MapIncidentPeekCard` slides up.
- [ ] **Search Box**: Input a location query; select an option and check if marker is dropped and camera relocates.

### 4. Incident Reporting
- [ ] **Validation Checks**: Verify "Submit report" remains disabled until a photo is picked, description length is $\ge 10$ characters, and location is set.
- [ ] **Map Picker**: Tap the Map Preview box; ensure it opens the full map picker to adjust the pinned hazard location.
- [ ] **Deduplication Check**: Attempt to report a duplicate hazard; confirm duplicate error dialog triggers.
