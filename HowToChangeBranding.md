# How to Rebrand a Flutter Desktop Application (Linux & Windows)

This guide explains how to fully rename a Flutter desktop app, update its window titles, configure its launcher icons, and ensure that the operating system's taskbar/dock and multitasking window managers associate the running app window with the correct branding.

---

## 1. Flutter Level (Cross-Platform)

Before modifying platform-specific folders, update the Flutter-level metadata:

### Application Window Fallback Title
*   **File**: `lib/main.dart`
*   **Action**: Locate the `MaterialApp` widget and update the `title` attribute:
    ```dart
    MaterialApp(
      title: 'YourAppName', // This controls the fallback window title
      ...
    )
    ```

---

## 2. Linux Desktop Branding

Linux desktop environments (like GNOME, KDE, and XFCE) rely on GTK properties and `.desktop` files to map running windows to launcher icons in the dock.

### Step 2.1: Update Binary Name and Application ID
*   **File**: `linux/CMakeLists.txt`
*   **Action**: Change the executable binary name (`BINARY_NAME`) and the GTK Application ID (`APPLICATION_ID`). 
    *   *Note: The Application ID must be a unique, reverse-DNS style name (e.g., `com.company.appname`).*
    ```cmake
    set(BINARY_NAME "your-binary-name")
    set(APPLICATION_ID "com.yourcompany.appname")
    ```

### Step 2.2: Update the Native Window Title
*   **File**: `linux/runner/my_application.cc`
*   **Action**: Locate the `my_application_activate` function and change the string in both title settings (GNOME headerbar title and fallback window title):
    ```cpp
    gtk_header_bar_set_title(header_bar, "Your Application Name");
    // and
    gtk_window_set_title(window, "Your Application Name");
    ```

### Step 2.3: Map the Dock Icon and Launcher (.desktop file)
For the operating system's dock/taskbar to link the running window with the app icon instead of showing a generic gear or blank icon:
1.  **Name the file exactly after the Application ID**: The file must be named `<APPLICATION_ID>.desktop` (e.g., `com.yourcompany.appname.desktop`).
2.  **Define properties inside the file**:
    ```ini
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Your Application Name        # The name shown in the Start Menu / Applications list
    Comment=A description of the app
    Exec=your-binary-name             # Must match the BINARY_NAME set in CMakeLists.txt
    Icon=your-icon-name               # The name of the icon file (without .png extension)
    Terminal=false
    Categories=Utility;
    ```
3.  **Place the files in target system paths**:
    *   **Desktop file**: Install to `/usr/share/applications/com.yourcompany.appname.desktop`
    *   **Branding icon PNG**: Copy your PNG icon to `/usr/share/pixmaps/your-icon-name.png` (matching the `Icon=` value in the `.desktop` file).

---

## 3. Windows Desktop Branding

Windows maps taskbar icons and shortcuts using PE (Portable Executable) binary resource headers and shell links.

### Step 3.1: Update Windows Binary Name
*   **File**: `windows/CMakeLists.txt`
*   **Action**: Change the binary output name:
    ```cmake
    set(BINARY_NAME "your-binary-name")
    ```

### Step 3.2: Update Executable Icon (.ico)
*   **File**: `windows/runner/resources/app_icon.ico`
*   **Action**: Replace this file with your own `.ico` file. This file contains the desktop/file explorer icon baked directly into the `.exe` file.

### Step 3.3: Edit Executable Metadata (Version Info)
To change the details shown in File Explorer (when hover-inspecting the `.exe` or viewing properties):
*   **File**: `windows/runner/Runner.rc`
*   **Action**: Locate the `VS_VERSION_INFO` block and edit the string fields:
    ```rc
    BEGIN
        VALUE "CompanyName", "Your Company" "\0"
        VALUE "FileDescription", "Your App Description" "\0"
        VALUE "FileVersion", "1.0.0" "\0"
        VALUE "InternalName", "your-binary-name" "\0"
        VALUE "LegalCopyright", "Copyright (C) 2026 Your Company" "\0"
        VALUE "OriginalFilename", "your-binary-name.exe" "\0"
        VALUE "ProductName", "Your Application Name" "\0"
        VALUE "ProductVersion", "1.0.0" "\0"
    END
    ```

### Step 3.4: Package in Windows Installer (Inno Setup Script)
If you package your app as a single `.exe` wizard installer:
*   Configure your script (`setup.iss`) to register shortcuts using the correct executable and name:
    ```ini
    #define MyAppName "Your Application Name"
    #define MyAppExeName "your-binary-name.exe"
    
    [Setup]
    AppName={#MyAppName}
    DefaultDirName={autopf}\{#MyAppName}
    OutputBaseFilename=your-installer-filename
    
    [Files]
    Source: "build\windows\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
    Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "{#MyAppExeName}"
    
    [Icons]
    Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
    Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
    ```
