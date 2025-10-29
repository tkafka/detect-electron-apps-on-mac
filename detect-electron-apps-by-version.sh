#!/usr/bin/env bash

running_procs=$(ps -eo comm= | sed 's|.*/||' | sort -u)

check_electron_version() {
    local major=$1 minor=$2 patch=$3
    [[ $major -gt 39 ]] || \
    [[ $major -eq 39 && $minor -ge 0 ]] || \
    [[ $major -eq 38 && $minor -gt 2 ]] || \
    [[ $major -eq 38 && $minor -eq 2 && $patch -ge 0 ]] || \
    [[ $major -eq 37 && $minor -gt 6 ]] || \
    [[ $major -eq 37 && $minor -eq 6 && $patch -ge 0 ]] || \
    [[ $major -eq 36 && $minor -gt 9 ]] || \
    [[ $major -eq 36 && $minor -eq 9 && $patch -ge 2 ]]
}

# Detect affected Electron versions
mdfind "kMDItemFSName == '*.app'" 2>/dev/null | sort | while IFS= read -r app; do
    [[ -f "$app/Contents/Frameworks/Electron Framework.framework/Resources/Info.plist" ]] || continue

    appName=$(basename "$app")
    appNameNoExt="${appName%.app}"

    # Check if running (faster lookup)
    if grep -Fxq "$appNameNoExt" <<< "$running_procs"; then
        runningStatus="🔵"
    else
        runningStatus="⚪️"
    fi

    # Get version
    electronVersion=$(plutil -extract CFBundleVersion raw "$app/Contents/Frameworks/Electron Framework.framework/Resources/Info.plist" 2>/dev/null)

    if [[ -z "$electronVersion" ]]; then
        echo "$runningStatus ⚠️  $appName (No Electron version)"
        continue
    fi

    IFS='.' read -r major minor patch <<< "$electronVersion"

    if check_electron_version "$major" "$minor" "$patch"; then
        echo "$runningStatus ✅ $appName ($electronVersion)"
    else
        echo "$runningStatus ❌ $appName ($electronVersion)"
    fi
done
