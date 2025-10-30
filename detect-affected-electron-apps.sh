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

# Use ripgrep when available
search_cmd="grep -aqF"
if command -v rg &>/dev/null; then
    search_cmd="rg -q --text -F"
fi

process_app() {
    local app="$1"
    local appName
    appName=$(basename "$app")
    local appNameNoExt="${appName%.app}"

    local runningStatus
    if echo "$RUNNING_PROCS" | grep -Fxq "$appNameNoExt"; then
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
export RUNNING_PROCS="$running_procs"
export SEARCH_CMD="$search_cmd"

{
    mdfind "kMDItemFSName == '*.app'" 2>/dev/null | while IFS= read -r app; do
        if [[ -f "$app/Contents/Frameworks/Electron Framework.framework/Resources/Info.plist" ]]; then
            echo "$app"
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
}
