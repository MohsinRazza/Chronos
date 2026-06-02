#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Building Chronos Linux Release bundle..."
flutter build linux --release

echo "📂 Setting up Debian package directory structure..."
STAGING_DIR="build/debian"

# Remove any previous staging directory to start fresh
rm -rf "$STAGING_DIR"

mkdir -p "$STAGING_DIR/DEBIAN"
mkdir -p "$STAGING_DIR/usr/bin"
mkdir -p "$STAGING_DIR/usr/lib/chronos"
mkdir -p "$STAGING_DIR/usr/share/applications"
mkdir -p "$STAGING_DIR/usr/share/pixmaps"

echo "📦 Copying build artifacts..."
cp -r build/linux/x64/release/bundle/* "$STAGING_DIR/usr/lib/chronos/"

echo "⚙️ Creating launcher script..."
cat << 'EOF' > "$STAGING_DIR/usr/bin/chronos"
#!/bin/sh
exec /usr/lib/chronos/chronos "$@"
EOF
chmod +x "$STAGING_DIR/usr/bin/chronos"

echo "🎨 Copying branding icon..."
if [ -f "assets/images/Chronos_C.png" ]; then
    cp assets/images/Chronos_C.png "$STAGING_DIR/usr/share/pixmaps/chronos.png"
else
    echo "⚠️ Warning: assets/images/Chronos_C.png not found, desktop icon might be blank."
fi

# Extract version from argument, defaulting to 0.10
VERSION=${1:-0.10}

echo "📝 Creating control file for version $VERSION..."
cat << EOF > "$STAGING_DIR/DEBIAN/control"
Package: chronos
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Depends: libc6, libgtk-3-0, libglib2.0-0, libstdc++6
Maintainer: Mohsin Razza <mohhsinnrazza@gmail.com>
Description: Chronos calendar application
  A premium, high-fidelity, offline-first desktop calendar application built with Flutter.
EOF

echo "🖥️ Creating desktop shortcut..."
cat << 'EOF' > "$STAGING_DIR/usr/share/applications/com.chronos.app.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Chronos
Comment=Offline-first desktop calendar
Exec=chronos
Icon=chronos
Terminal=false
Categories=Office;Calendar;
EOF

echo "🏗️ Packaging Debian archive..."
dpkg-deb --root-owner-group --build "$STAGING_DIR" "build/chronos-${VERSION}-amd64.deb"

echo "🎉 Success! Built: build/chronos-${VERSION}-amd64.deb"
