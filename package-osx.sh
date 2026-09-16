#!/bin/bash

Arch="$1"
OutputPath="$2"
Version="$3"

echo "=== macOS packaging debug ==="
echo "Arch       : $Arch"
echo "OutputPath : $OutputPath"
echo "Version    : $Version"
echo "Runner     : $(uname -a)"
echo "Machine    : $(uname -m)"
echo "============================="

FileName="v2rayN-${Arch}.zip"

echo
echo "=== Download core package ==="
echo "FileName: $FileName"
echo "URL: https://github.com/2dust/v2rayN-core-bin/raw/refs/heads/master/$FileName"

wget -nv -O "$FileName" \
    "https://github.com/2dust/v2rayN-core-bin/raw/refs/heads/master/$FileName"

echo
echo "=== Extract ==="
7z x "$FileName"

echo
echo "=== Core package Xray ==="
file "v2rayN-${Arch}/bin/xray/xray"

echo
echo "=== Core package v2rayN ==="
file "v2rayN-${Arch}/v2rayN"

echo
echo "=== Existing build artifact ==="
file "$OutputPath/v2rayN"
if [ -f "$OutputPath/bin/xray/xray" ]; then
    file "$OutputPath/bin/xray/xray"
else
    echo "No Xray in build artifact"
fi

echo
echo "=== Copy core package to output ==="
cp -rf "v2rayN-${Arch}/"* "$OutputPath"

echo
echo "=== Output after copy ==="
file "$OutputPath/v2rayN"
file "$OutputPath/bin/xray/xray"

PackagePath="v2rayN-Package-${Arch}"
mkdir -p "$PackagePath/v2rayN.app/Contents/Resources"

echo
echo "=== Create app bundle ==="
cp -rf "$OutputPath" "$PackagePath/v2rayN.app/Contents/MacOS"
cp -f "$PackagePath/v2rayN.app/Contents/MacOS/v2rayN.icns" \
      "$PackagePath/v2rayN.app/Contents/Resources/AppIcon.icns"

echo "When this file exists, app will not store configs under this folder" \
    > "$PackagePath/v2rayN.app/Contents/MacOS/NotStoreConfigHere.txt"

chmod +x "$PackagePath/v2rayN.app/Contents/MacOS/v2rayN"

echo
echo "=== App bundle Xray ==="
file "$PackagePath/v2rayN.app/Contents/MacOS/bin/xray/xray"

echo
echo "=== App bundle v2rayN ==="
file "$PackagePath/v2rayN.app/Contents/MacOS/v2rayN"

cat >"$PackagePath/v2rayN.app/Contents/Info.plist" <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleLocalizations</key>
  <array>
    <string>zh-Hans</string>
    <string>zh-Hant</string>
    <string>en</string>
    <string>fa</string>
    <string>fr</string>
    <string>ru</string>
    <string>hu</string>
  </array>
  <key>CFBundleDisplayName</key>
  <string>v2rayN</string>
  <key>CFBundleExecutable</key>
  <string>v2rayN</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIconName</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>2dust.v2rayN</string>
  <key>CFBundleName</key>
  <string>v2rayN</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${Version}</string>
  <key>CSResourcesFileMapped</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>LSMinimumSystemVersion</key>
  <string>13.6</string>
</dict>
</plist>
EOF

echo
echo "=== Create DMG ==="
create-dmg \
    --volname "v2rayN Installer" \
    --window-size 700 420 \
    --icon-size 100 \
    --icon "v2rayN.app" 160 185 \
    --hide-extension "v2rayN.app" \
    --app-drop-link 500 185 \
    "v2rayN-${Arch}.dmg" \
    "$PackagePath/v2rayN.app"

echo
echo "=== Final DMG ==="
ls -lh "v2rayN-${Arch}.dmg"

echo
echo "=== Packaging finished ==="
