# Chronos Branding Changes Documentation

This document logs all changes made to transition the project from the default Flutter starter branding (`calendar`) to the **Chronos** product identity.

---

## 1. Application Name & Windows Titles

To ensure the user only sees "Chronos" instead of the default name "calendar" across the operating system interface:

*   **Window Title Manager (GTK Linux Runner)**:
    *   **File**: [`linux/runner/my_application.cc`](file:///storage/Codebase/Flutter/Projects/calendar/linux/runner/my_application.cc)
    *   **Change**: Modified the window decoration and GNOME header bar setup to set the native title to `"Chronos"`:
        ```cpp
        gtk_header_bar_set_title(header_bar, "Chronos");
        // and
        gtk_window_set_title(window, "Chronos");
        ```
*   **Flutter MaterialApp Title**:
    *   **File**: [`lib/main.dart`](file:///storage/Codebase/Flutter/Projects/calendar/lib/main.dart)
    *   **Change**: Updated the application entry point's title value to `'Chronos'`.
        ```dart
        MaterialApp(
          title: 'Chronos',
          ...
        )
        ```

---

## 2. Desktop Launcher Identity & ID Mapping

To ensure multitasking docks, task managers, and the system Application Menu map the application window correctly to the launcher shortcut:

*   **Executable Binary & Application ID**:
    *   **File**: [`linux/CMakeLists.txt`](file:///storage/Codebase/Flutter/Projects/calendar/linux/CMakeLists.txt)
    *   **Change**: Set the output binary executable name to `chronos` and updated the unique Application ID to `com.chronos.app`:
        ```cmake
        set(BINARY_NAME "chronos")
        set(APPLICATION_ID "com.chronos.app")
        ```
*   **Linux Desktop Shortcut (.desktop File)**:
    *   **File**: Managed via [`build_deb.sh`](file:///storage/Codebase/Flutter/Projects/calendar/build_deb.sh)
    *   **Change**: Configures a launcher shortcut named `com.chronos.app.desktop` pointing to the new executable and icon:
        ```ini
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Chronos
        Comment=Offline-first desktop calendar
        Exec=chronos
        Icon=chronos
        Terminal=false
        Categories=Office;Calendar;
        ```

---

## 3. Launcher Icons & Visual Assets

*   **Branding Asset**:
    *   **Source File**: [`assets/images/Chronos_C.png`](file:///storage/Codebase/Flutter/Projects/calendar/assets/images/Chronos_C.png)
*   **Linux Icon Configuration**:
    *   **Install Destination**: `/usr/share/pixmaps/chronos.png`
    *   **Change**: The packaging script copies `assets/images/Chronos_C.png` to `/usr/share/pixmaps/chronos.png` so the operating system can map the `Icon=chronos` parameter in the desktop entry.

---

## 4. Windows Packaging Installer (Inno Setup)

*   **Installer configuration**:
    *   **File**: [`windows_setup.iss`](file:///storage/Codebase/Flutter/Projects/calendar/windows_setup.iss)
    *   **Change**: Configured custom app details and output metadata for the Windows wizard installer:
        ```ini
        #define MyAppName "Chronos"
        #define MyAppVersion "0.10"
        #define MyAppPublisher "Mohsin Razza"
        #define MyAppExeName "chronos.exe"
        OutputBaseFilename=chronos-0.10-setup
        ```
