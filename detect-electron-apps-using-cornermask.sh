#!/usr/bin/env bash
# Directly detect Electron apps using the _cornerMask override - thanks avarayr!
mdfind "kMDItemFSName == '*.app'" | sort --ignore-case | while read app; do
  electronFiles=$(find "$app" -name "Electron Framework" -type f 2>/dev/null)
  
  if [[ -n "$electronFiles" ]]; then
    appName=$(basename "$app")
    
    while IFS= read -r filename; do
      if [[ -f "$filename" ]]; then
        ev=$(grep -aoE 'Chrome/.*Electron/[0-9]+(\.[0-9]+){1,3}' -- "$filename" 2>/dev/null | head -n1 | sed -E 's/.*Electron\/([0-9]+(\.[0-9]+){1,3}).*/\1/')
        [ -z "$ev" ] && ev=$(grep -aoE 'Electron/[0-9]+(\.[0-9]+){1,3}' -- "$filename" 2>/dev/null | head -n1 | sed -E 's/.*Electron\/([0-9]+(\.[0-9]+){1,3}).*/\1/')
        
        relativePath=$(echo "$filename" | sed "s|$app/||")
        
        if grep -aqF "_cornerMask" -- "$filename" 2>/dev/null; then
          echo "❌ $appName (Electron ${ev:-unknown}) - $relativePath"
        else
          echo "✅ $appName (Electron ${ev:-unknown}) - $relativePath"
        fi
        break
      fi
    done <<< "$electronFiles"
  fi
done
