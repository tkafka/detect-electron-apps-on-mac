#!/usr/bin/env bash
# NOTE: You need to run this script from the terminal as ./detect-running-affected-electron-apps.sh, this one won't work if you simply paste the file contents into the terminal
#
# Usage: ./detect-running-affected-electron-apps.sh [--fast]
#   --fast: Only check standard locations (faster but may miss nested apps like Docker Desktop)

# Parse command line arguments
FAST_MODE=false
if [[ "$1" == "--fast" ]]; then
    FAST_MODE=true
fi


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

# Use ripgrep when available
search_cmd="grep -aqF"
extract_cmd="grep -oE"
if command -v rg &>/dev/null; then
    search_cmd="rg -q --text -F"
    extract_cmd="rg -o"
fi

# Use fd when available (2.3x faster than find!)
if command -v fd &>/dev/null; then
    find_cmd="fd -t f"
else
    find_cmd="find"
    if [[ "$FAST_MODE" != "true" ]]; then
        echo "💡 Tip: Install fd for faster performance: brew install fd" >&2
        echo "" >&2
    fi
fi

process_app() {
    local app="$1"
    local appName
    appName=$(basename "$app")
    local appNameNoExt="${appName%.app}"

    local runningStatus
    # Use pgrep for accurate detection of running apps
    # Check if ANY executable from the app's MacOS directory is running
    if pgrep -f "^$app/Contents/MacOS/" >/dev/null 2>&1; then
        runningStatus="🔵"
    else
        runningStatus="⚪️"
    fi

    local electronVersion
    electronVersion=$(plutil -extract CFBundleVersion raw "$app/Contents/Frameworks/Electron Framework.framework/Resources/Info.plist" 2>/dev/null)

    local versionVulnerable
    if [[ -z "$electronVersion" ]]; then
        versionVulnerable=true
        electronVersion="unknown"
    else
        # Split version string on dots (e.g., "37.6.0" → major=37, minor=6, patch=0)
        IFS='.' read -r major minor patch <<< "$electronVersion"
        if check_electron_version "$major" "$minor" "$patch"; then
            versionVulnerable=false
        else
            versionVulnerable=true
        fi
    fi

    local electronBinary="$app/Contents/Frameworks/Electron Framework.framework/Electron Framework"
    local status
    if [[ "$versionVulnerable" == true ]]; then
        # Apps with both old version AND _cornerMask binary symbol are affected
        if [[ -f "$electronBinary" ]] && $SEARCH_CMD "_cornerMask" "$electronBinary" 2>/dev/null; then
            status="⚠️"
        else
            status="🔄"
        fi
    else
        status="✅"
    fi

    echo "$runningStatus|$status|$appName|$electronVersion"
}

# Export functions and variables so xargs subshells can access them
export -f process_app
export -f check_electron_version
export SEARCH_CMD="$search_cmd"
export EXTRACT_CMD="$extract_cmd"
export FIND_CMD="$find_cmd"
export FAST_MODE="$FAST_MODE"

{
    mdfind "kMDItemFSName == '*.app'" 2>/dev/null | while IFS= read -r app; do
        # Check standard location
        if [[ -f "$app/Contents/Frameworks/Electron Framework.framework/Resources/Info.plist" ]]; then
            echo "$app"
        elif [[ "$FAST_MODE" != "true" ]]; then
            # Only do deep search if not in fast mode
            # Search entire app bundle for nested Electron apps at any depth
            if [[ "$FIND_CMD" == "fd -t f" ]]; then
                $FIND_CMD Info.plist "$app" 2>/dev/null | grep "Electron Framework" | $EXTRACT_CMD '^.*\.app'
            else
                $FIND_CMD "$app" -type f -name "Info.plist" -path "*Electron Framework*" 2>/dev/null | $EXTRACT_CMD '^.*\.app'
            fi
        fi
    done
    # -P 0 runs unlimited parallel processes, _ is placeholder for $0, {} becomes $1
} | xargs -P 0 -I {} bash -c 'process_app "$1"' _ '{}' | {
    all_data=$(cat)

    max_app_len=0
    while IFS='|' read -r _ _ app _; do
        len=${#app}
        [[ $len -gt $max_app_len ]] && max_app_len=$len
    done <<< "$all_data"

    echo "$all_data" | sort -t'|' -k3 | while IFS='|' read -r running status app version; do
        printf "%-3s  %-3s  %-${max_app_len}s  %s\n" "$running" "$status" "$app" "$version"
    done

    echo
    echo "🔵 = Running, ⚪️ = Not running"
    echo "✅ = Updated, 🔄 = Outdated, ⚠️ = Affected (contains _cornerMask)"
    [[ "$FAST_MODE" == "true" ]] && echo "⚡ Fast mode: only checking standard locations"
}
