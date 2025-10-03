# Detect affected Electron versions
mdfind "kMDItemFSName == '*.app'" | while read app; do
  electronFiles=$(find "$app" -name "Electron Framework" -type f 2>/dev/null)
  
  if [[ -n "$electronFiles" ]]; then
    appName=$(basename "$app")
    
    while IFS= read -r filename; do
      electronVersion=$(strings "$filename" | grep "Chrome/" | grep -i Electron | grep -v '%s' | sort -u | cut -f 3 -d '/')
      
      if [[ -n "$electronVersion" ]]; then
        IFS='.' read -r major minor patch <<< "$electronVersion"
        
        relativePath=$(echo "$filename" | sed "s|$app/||")
        
        if [[ $major -gt 39 ]] || \
           [[ $major -eq 39 && $minor -ge 0 ]] || \
           [[ $major -eq 38 && $minor -gt 2 ]] || \
           [[ $major -eq 38 && $minor -eq 2 && $patch -ge 0 ]] || \
           [[ $major -eq 37 && $minor -gt 6 ]] || \
           [[ $major -eq 37 && $minor -eq 6 && $patch -ge 0 ]] || \
           [[ $major -eq 36 && $minor -gt 9 ]] || \
           [[ $major -eq 36 && $minor -eq 9 && $patch -ge 2 ]]; then
          echo "✅ $appName: Electron $electronVersion ($relativePath)"
        else
          echo "❌ $appName: Electron $electronVersion ($relativePath)"
        fi
        break
      fi
    done <<< "$electronFiles"
  fi
done