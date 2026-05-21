# BaKhabar Alerts — UI/UX Design System

This design system documents the premium dark-themed visual assets, typography, responsive grid settings, and custom widgets used inside the mobile client.

---

## 🎨 Color Palette

The app employs a deep, dark glassmorphism aesthetic to emphasize readability and crisis urgency.

### Core Tokens
- **Background**: `#121212` (Solid deep dark layout background)
- **Surface**: `#1E1E1E` (Panel surfaces, cards background)
- **Surface Elevated**: `#2D2D2D` (Secondary button containers)
- **Map Accent**: `#2196F3` / `#00E5FF` (Dynamic light cyan/blue mapping color)

### Severity Priority Coding
- 🔴 **Critical**: `#FF3B30` (IncidentPriority.critical)
- 🟠 **High**: `#FF9500` (IncidentPriority.high)
- 🟡 **Medium**: `#FFCC00` (IncidentPriority.medium)
- 🟢 **Low**: `#34C759` (IncidentPriority.low)

### Glassmorphism Overlays
- **Glass Panel**: `rgba(30, 30, 30, 0.7)` with background blur filters.
- **Glass Border**: `rgba(255, 255, 255, 0.08)` to frame items cleanly.

---

## 📐 Spacing & Layout Constraints (`AppDimens`)

The layout scales using the `flutter_screenutil` library. The base design canvas size is **393x852 px** (standard viewport layout).

- **Standard Margins**:
  - Small Spacing: `8.w`/`8.h`
  - Body Margins: `16.w` / `24.w`
- **Border Radius**:
  - Small elements (e.g. status tags): `4.r`
  - Medium elements (e.g. card contours): `12.r`
  - Large elements (e.g. map previews): `16.r`
  - Pill widgets (e.g. tag badges): `100.r`

---

## ✍️ Typography (`AppTextStyles`)

The app uses **Outfit** via Google Fonts. Text sizing handles cross-device scaling automatically:

- **Alerts Title (App Bar)**: `20.sp` / Bold / Spacing `1.2`
- **Screen Title**: `24.sp` / Bold / Spacing `1.1`
- **Section Headers**: `16.sp` / SemiBold
- **Incident Card Title**: `14.sp` / SemiBold / Line Height `1.3`
- **Metadata Labels**: `11.sp` / Regular / Muted colors

---

## 🧩 Premium Custom Components

### 1. `CiroBottomNav`
Custom navigation bar with semi-transparent glass panel backdrop and animated transition indicators matching active tab selections.

### 2. `SeverityFilterChip`
Selectable, outline-bordered filter chips changing colors based on severity states.

### 3. `MapIncidentPeekCard`
A horizontal slide-up card that dynamically overlays Google Maps to display a localized hazard preview with quick access actions.
