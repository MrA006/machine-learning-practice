#!/usr/bin/env bash
# track_large_lfs.sh
# Finds untracked files >10MB and adds them to Git LFS.

# Size threshold (in bytes): 10 * 1024 * 1024 = 10 485 760
THRESHOLD=$((10 * 1024 * 1024))

echo "🔍 Scanning for untracked files >10 MB…"
files_found=0

# List untracked files, filter by size, track & add via LFS
git ls-files --others --exclude-standard | while read -r file; do
  if [ -f "$file" ]; then
    size=$(stat -c%s "$file")
    if [ "$size" -gt "$THRESHOLD" ]; then
      echo "  ➡️  Tracking with LFS: $file ($(printf '%.1f' "$(bc -l <<<"$size/1024/1024")") MB)"
      git lfs track "$file"
      git add "$file"
      files_found=$((files_found + 1))
    fi
  fi
done

if [ "$files_found" -gt 0 ]; then
  echo "📝 Staging .gitattributes…"
  git add .gitattributes
  echo "✅ Done! $files_found file(s) staged for LFS."
  echo "Next: git commit -m \"Track large files with LFS\" && git push"
else
  echo "✅ No untracked files >10 MB found."
fi
