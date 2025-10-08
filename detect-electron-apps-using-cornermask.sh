# Directly detect Electron apps using the _cornerMask override - thanks avarayr!
if [[ ! -f $(which rg) ]]; then
  echo "❌ this script requires ripgrep, you can install it with: brew install ripgrep"
  exit 1
fi

mdfind "kMDItemFSName == '*.app'" | sort --ignore-case | while read app; do
  electronFiles=$(find "$app" -name "Electron Framework" -type f 2>/dev/null)
  
  if [[ -n "$electronFiles" ]]; then
    appName=$(basename "$app")
    
    while IFS= read -r filename; do
      if [[ -f "$filename" ]]; then
        ev=$(rg -a -m1 -o -r '$1' 'Chrome/.*Electron/([0-9]+(\.[0-9]+){1,3})' -- "$filename" 2>/dev/null)
        [ -z "$ev" ] && ev=$(rg -a -m1 -o -r '$1' 'Electron/([0-9]+(\.[0-9]+){1,3})' -- "$filename" 2>/dev/null)
        
        relativePath=$(echo "$filename" | sed "s|$app/||")
        
        if rg -a -q -F "_cornerMask" -- "$filename" 2>/dev/null; then
          echo "❌ $appName (Electron ${ev:-unknown}) - $relativePath"
        else
          echo "✅ $appName (Electron ${ev:-unknown}) - $relativePath"
        fi
        break
      fi
    done <<< "$electronFiles"
  fi
done
