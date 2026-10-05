#!/usr/bin/env bash
# Generate the auto-updates block in updates.md from git history (last 30 days).
# Tuned for release-notes readability: one bullet per new/updated guide, capped site list.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PAGE="${ROOT}/updates.md"
SITE_LIMIT=15

if date -u -d '30 days ago' +%Y-%m-%d >/dev/null 2>&1; then
  SINCE="$(date -u -d '30 days ago' +%Y-%m-%d)"
else
  SINCE="$(date -u -v-30d +%Y-%m-%d)"
fi
TODAY="$(date -u +%Y-%m-%d)"
BEGIN_MARK="<!-- BEGIN:AUTO-UPDATES -->"
END_MARK="<!-- END:AUTO-UPDATES -->"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

NEW_LIST="${WORKDIR}/new.txt"
UPD_LATEST="${WORKDIR}/upd.txt"
SITE_LIST="${WORKDIR}/site.txt"
GEN="${WORKDIR}/gen.md"
: > "$NEW_LIST"
: > "$UPD_LATEST"
: > "$SITE_LIST"

is_meta_guide() {
  case "$1" in
    README-best-practices*.md|README.md) return 0 ;;
    *) return 1 ;;
  esac
}

guide_title() {
  local file="$1"
  local title=""
  if [[ -f "$file" ]]; then
    title="$(grep -m1 -E '^# |^<h1' "$file" 2>/dev/null \
      | sed -E 's/^# //; s/<h1[^>]*>//; s/<\/h1>//; s/<[^>]+>//g; s/\\+//' \
      | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || true)"
  fi
  # Skip stub redirects
  if [[ "$title" == "This content moved" ]]; then
    title=""
  fi
  if [[ -z "$title" ]]; then
    title="${file%.md}"
    title="${title#README-}"
    title="${title//-/ }"
  fi
  printf '%s' "$title"
}

guide_href() {
  local file="$1"
  printf '{{ "/%s" | relative_url }}' "${file%.md}"
}

# --- New guides (unique files) ---
current_subject=""
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^[0-9a-f]+\| ]]; then
    current_subject="${line#*|}"
    current_subject="${current_subject%%|*}"
  elif [[ "$line" == README-*.md ]] && ! is_meta_guide "$line"; then
    if ! grep -q "^${line}|" "$NEW_LIST" 2>/dev/null; then
      printf '%s|%s\n' "$line" "$current_subject" >> "$NEW_LIST"
    fi
  fi
done < <(git log --since="$SINCE" --pretty=format:'%h|%s|%ad' --date=short \
  --no-merges --diff-filter=A --name-only -- 'README-*.md')

# --- Guide updates: first (newest) subject per file, skip newly added files ---
current_subject=""
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^[0-9a-f]+\| ]]; then
    current_subject="${line#*|}"
  elif [[ "$line" == README-*.md ]] && ! is_meta_guide "$line"; then
    if grep -q "^${line}|" "$NEW_LIST" 2>/dev/null; then
      continue
    fi
    # Keep only the newest subject per file (git log is newest-first)
    if ! grep -q "^${line}|" "$UPD_LATEST" 2>/dev/null; then
      printf '%s|%s\n' "$line" "$current_subject" >> "$UPD_LATEST"
    fi
  fi
done < <(git log --since="$SINCE" --pretty=format:'%h|%s' --no-merges \
  --diff-filter=M --name-only -- 'README-*.md')

# --- Site / tooling: newest first, capped ---
while IFS= read -r subject || [[ -n "$subject" ]]; do
  [[ -z "$subject" ]] && continue
  case "$subject" in
    Merge\ *) continue ;;
    "chore: refresh What's New"*) continue ;;
  esac
  if ! grep -qxF "$subject" "$SITE_LIST" 2>/dev/null; then
    printf '%s\n' "$subject" >> "$SITE_LIST"
  fi
done < <(git log --since="$SINCE" --pretty=format:'%s' --no-merges -- \
  'index.md' '_layouts/' 'assets/css/' 'best-practices.md' 'reviews.md' \
  'aiops-use-cases.md' 'guide-types.md' '_config.yml' '.github/workflows/')

{
  echo "*Rolling window: ${SINCE} to ${TODAY}. Regenerated weekly from git history.*"
  echo ""
  echo "### New guides"
  echo ""
  if [[ ! -s "$NEW_LIST" ]]; then
    echo "_No new guides in the last 30 days._"
  else
    sort -t'|' -k1,1 "$NEW_LIST" | while IFS='|' read -r file subject; do
      title="$(guide_title "$file")"
      href="$(guide_href "$file")"
      echo "- [${title}](${href}) -- ${subject}"
    done
  fi
  echo ""
  echo "### Guide updates"
  echo ""
  if [[ ! -s "$UPD_LATEST" ]]; then
    echo "_No notable guide updates in the last 30 days._"
  else
    sort -t'|' -k1,1 "$UPD_LATEST" | while IFS='|' read -r file subject; do
      title="$(guide_title "$file")"
      href="$(guide_href "$file")"
      echo "- [${title}](${href}): ${subject}"
    done
  fi
  echo ""
  echo "### Site and tooling"
  echo ""
  if [[ ! -s "$SITE_LIST" ]]; then
    echo "_No site or tooling changes in the last 30 days._"
  else
    # Already newest-first from git log; take first SITE_LIMIT
    head -n "$SITE_LIMIT" "$SITE_LIST" | while IFS= read -r subject; do
      echo "- ${subject}"
    done
    total="$(wc -l < "$SITE_LIST" | tr -d ' ')"
    if [[ "$total" -gt "$SITE_LIMIT" ]]; then
      echo ""
      echo "_…and $((total - SITE_LIMIT)) more site commits in this window._"
    fi
  fi
  echo ""
} > "$GEN"

if [[ ! -f "$PAGE" ]]; then
  echo "error: $PAGE does not exist -- create it with AUTO-UPDATES markers first" >&2
  exit 1
fi

if ! grep -qF "$BEGIN_MARK" "$PAGE" || ! grep -qF "$END_MARK" "$PAGE"; then
  echo "error: $PAGE missing AUTO-UPDATES markers" >&2
  exit 1
fi

OUT="${WORKDIR}/out.md"
awk -v begin="$BEGIN_MARK" -v end="$END_MARK" -v genfile="$GEN" '
  $0 == begin { print; system("cat \"" genfile "\""); skip=1; next }
  $0 == end { skip=0; print; next }
  !skip { print }
' "$PAGE" > "$OUT"

mv "$OUT" "$PAGE"
echo "Updated $PAGE for window ${SINCE} → ${TODAY}"
