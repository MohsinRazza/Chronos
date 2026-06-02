# Chronos 🕒

Chronos is a premium, high-fidelity, offline-first desktop calendar application built with Flutter. Driven by modern design patterns and a custom **shadcn/ui** inspired visual language, it offers a seamless blend of local organization and cloud synchronization.

---

## Key Features

### 🎨 Custom Shadcn-Style Design System
- **Pixel-Perfect Aesthetics**: High-contrast, clean visual design utilizing micro-animations, smooth hover states, and standard layout dividers.
* **Poppins Typography**: Fully integrated Poppins typeface powered by Google Fonts.
- **Premium Toast System**: Bottom-right desktop notifications featuring custom slide-in animations, dynamic icons, and variant support (success, sync, destructive).
- **Flexible UI Layouts**: A collapsible left-sidebar agenda that adapts its height dynamically depending on the active day's events, maximizing space for the upcoming events timeline.

### 🌐 Google Calendar Sync (Offline-First)
- **OAuth Loopback Flow**: Secure desktop authentication through the standard web browser flow, logging in directly via your Google Account.
- **Offline Caching**: Built with a local-first philosophy. Cached events are saved to local memory so you can view, edit, and keep up with your schedule even without internet access.
- **Session Auto-Persistence**: Tracks user authentication sessions and handles credentials securely with local persistence. Includes a 15-day session expiration limit.
- **Sync Status Monitor**: A top-right indicator chip showing network connectivity (emerald for online, red for offline), relative last-sync elapsed time (e.g., "5m ago"), and a detailed tooltip with complete sync logs.

### 🌈 Multiple Theme Presets
Transition instantly between four meticulously curated presets, available in both **Light** and **Dark** modes:
1. **Zinc** (Default Monochrome)
2. **Olive** (Warm natural greens and tinted light-yellow/grey card layouts)
3. **Sky** (Clean sky-blue highlights with deep navy backgrounds)
4. **Cyan** (Energetic teal and fresh cyan-accented styling)

Theme choices are persisted locally in memory and reload automatically when starting the application.

---

## Getting Started

### 📋 Prerequisites
Make sure you have the following installed on your system:
- **Flutter SDK**: `^3.0.0` or higher
- **Dart SDK**: `^3.0.0` or higher

### 🚀 Running the Application
1. Clone this repository to your local workspace.
2. Run package resolution to fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application in development mode:
   ```bash
   flutter run
   ```

---

## 🔒 Configuration

To enable Google Calendar synchronization, you must set up your OAuth 2.0 credentials:
1. Create a project on the **Google Cloud Console**.
2. Enable the **Google Calendar API**.
3. Create an **OAuth 2.0 Client ID** configured as a **Desktop Application**.
4. Define your credentials in `lib/config/google_oauth_config.dart` (which is git-ignored by default to protect secrets):
   ```dart
   class GoogleOAuthConfig {
     static const String clientId = 'YOUR_CLIENT_ID.apps.googleusercontent.com';
     static const String clientSecret = 'YOUR_CLIENT_SECRET';
   }
   ```

---

## 📂 File Structure

* `lib/main.dart` — Main entry point, state lifecycle manager, and dashboard wrapper.
* `lib/theme/shadcn_theme.dart` — Custom design system, typography variables, theme extension mapping, and color preset palettes.
* `lib/services/google_calendar_service.dart` — Handles OAuth authentication, loopback token exchanges, caching, and local UTC timezone mappings.
* `lib/widgets/` — Premium reusable widgets:
  - `right_sidebar.dart` — Contains search, actions menu, category filter list, account details, and theme presets selector.
  - `sidebar.dart` — Flexible left sidebar detailing date selection and the adaptive agenda.
  - `calendar_views.dart` — Modular month, week, and day view render engines.
  - `shad_toast.dart` — Fixed bottom-right toast notification overlay manager.
  - `shad_button.dart` / `shad_input.dart` / `shad_dialog.dart` — Core design component primitives.
