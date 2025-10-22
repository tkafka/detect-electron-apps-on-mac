#!/usr/bin/env bash
# Detect affected Electron versions
find /Applications /System/Applications ~/Applications -name "*.app" -type d 2>/dev/null | sort --ignore-case | while read -r app; do
  appName=$(basename "$app")
  electronFrameworkInfo="$app/Contents/Frameworks/Electron Framework.framework/Resources/Info.plist"
  if [[ -f "$electronFrameworkInfo" ]]; then
    electronVersion=$(plutil -extract CFBundleVersion raw "$electronFrameworkInfo")
      if [[ $? -eq 1 || -z "$electronVersion" ]]; then
      echo "⚠️  $appName (No Electron version)"
    else
      IFS='.' read -r major minor patch <<< "$electronVersion"
          
      if [[ $major -gt 39 ]] || \
        [[ $major -eq 39 && $minor -ge 0 ]] || \
        [[ $major -eq 38 && $minor -gt 2 ]] || \
        [[ $major -eq 38 && $minor -eq 2 && $patch -ge 0 ]] || \
        [[ $major -eq 37 && $minor -gt 6 ]] || \
        [[ $major -eq 37 && $minor -eq 6 && $patch -ge 0 ]] || \
        [[ $major -eq 36 && $minor -gt 9 ]] || \
        [[ $major -eq 36 && $minor -eq 9 && $patch -ge 2 ]]; then
        echo "✅ $appName ($electronVersion)"
      else
        echo "❌️ $appName ($electronVersion)"
      fi
    fi
  fi
done
