#!/usr/bin/env bash
# track_all_large_lfs.sh
# Finds every file >10 MB and makes sure it’s tracked by Git LFS.

THRESHOLD=$((10 * 1024 * 1024))

echo "🔍 Scanning for ALL files >10 MB…"
found=0

# Use find to get every file >THRESHOLD, skip .git folder
find . -type f -size +"${THRESHOLD}"c -not -path './.git/*' | while read -r f; do
  # strip leading './'
  file="${f#./}"

  # Check if already in LFS (by path in .gitattributes)
  if git lfs ls-files | awk '{print $2}' | grep -Fxq "$file"; then
    echo "   ✔ already LFS-tracked: $file"
  else
    echo "   ➡️  adding to LFS:         $file"
    git lfs track "$file"
    git add "$file"
    found=$((found+1))
  fi
done

if (( found > 0 )); then
  echo "📝 Staging updated .gitattributes…"
  git add .gitattributes
  echo "✅ Done: $found new file(s) staged under LFS."
  echo "Next: git commit -m \"Track all >10MB files with LFS\" && git push"
else
  echo "✅ All >10MB files are already tracked by LFS."
fi
