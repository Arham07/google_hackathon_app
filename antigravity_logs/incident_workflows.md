# BaKhabar Alerts — Incident Workflows & Lifecycles

This document describes the end-to-end data lifecycle of a crisis alert, including client-side filtering, geospatial focus transitions, and report submission flows.

---

## 🔁 Incident Data Lifecycle

```mermaid
sequenceDiagram
    participant C as Citizen Mobile App
    participant Co as IncidentsController
    participant B as Backend API
    participant S as Supabase Storage / DB

    C->>Co: Initialize app or switch tab
    Co->>Co: Increment load generation
    Co->>B: GET /api/events (with city & filters)
    Note over B: Query DB & return json
    B->>Co: 200 OK (Events list)
    Co->>Co: Parse JSON to Incident models
    Co->>C: notifyListeners()
    C->>C: Rebuild List & Map view
```

---

## 🗺️ Geospatial Focus Transition (List ➔ Map)

When a citizen views an incident in the feed list and taps the **Open on Map** action, the following transition occurs:

```mermaid
graph TD
    A[Citizen taps 'Open on Map' on IncidentCard] --> B[IncidentsController: requestMapFocus incident, switchToMapTab: true]
    B --> C[MainShell listens: switches tab index to 1 Map]
    C --> D[MapTabScreen wakes up and drains pending focus]
    D --> E[Animate camera to target coordinates zoom: 15]
    E --> F[Show MapIncidentPeekCard overlay on Map screen]
```

---

## ✍️ Citizen Report Submission Pipeline

Reporting a hazard from the field involves file capture, location picking, and server-side deduplication validation:

```mermaid
graph TD
    A[Citizen navigates to Report tab] --> B[Retrieve GPS lat/lng for initial map preview]
    B --> C[Optionally open LocationPickerScreen to adjust PIN]
    C --> D[Optionally invoke ImagePicker camera / gallery]
    D --> E[Check validation: text.length >= 10 and photo != null]
    E -->|Submit tapped| F[Compile Multipart FormData package]
    F --> G[POST /api/user-reports/submit]
    G --> H{Server Response}
    H -->|status: success| I[Show success dialog & clear form values]
    H -->|status: duplicate| J[Show duplicate warning alert]
    H -->|ApiException / error| K[Show error snackbar & retain inputs]
```
