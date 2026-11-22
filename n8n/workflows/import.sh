#!/bin/sh
# One-shot import of the CtrlHub workflows into n8n (run by the n8n-init
# compose service). Workflows carry fixed IDs, so re-running this overwrites
# them instead of creating duplicates.
set -eu

DIR="${WORKFLOW_DIR:-/workflows}"

if ! command -v n8n >/dev/null 2>&1; then
  echo "n8n CLI not found in PATH" >&2
  exit 1
fi

echo "n8n version: $(n8n --version 2>/dev/null || echo unknown)"
echo "importing workflows from $DIR"
n8n import:workflow --separate --input="$DIR"

# Activate each imported workflow. n8n 1.x uses update:workflow; if the CLI
# changes, import still succeeds and workflows can be activated in the UI.
if n8n update:workflow --help >/dev/null 2>&1; then
  for file in "$DIR"/*.json; do
    id=$(sed -n 's/^  "id": "\([^"]*\)".*/\1/p' "$file" | head -n 1)
    [ -n "$id" ] || continue
    echo "activating $id"
    n8n update:workflow --id="$id" --active=true || echo "warn: could not activate $id"
  done
else
  echo "warn: update:workflow unavailable; activate workflows in the n8n UI"
fi

echo "workflows imported"
