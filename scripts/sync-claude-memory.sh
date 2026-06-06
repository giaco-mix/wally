#!/usr/bin/env bash
# Reinstalla la memoria di Claude Code (versionata in docs/claude-memory/)
# nella cartella locale di Claude per QUESTO device.
#
# Claude Code deriva il nome della cartella memory dal path assoluto del
# progetto, sostituendo i caratteri non alfanumerici con "-". Questo script
# lo calcola da solo, quindi funziona qualunque sia il percorso di clone.
#
# Uso:  bash scripts/sync-claude-memory.sh
set -euo pipefail

# Radice del repo (questo script sta in scripts/)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Codifica del path come fa Claude Code: ogni char non [A-Za-z0-9] -> "-"
ENC="$(printf '%s' "$PROJECT_DIR" | sed 's/[^a-zA-Z0-9]/-/g')"
DEST="$HOME/.claude/projects/$ENC/memory"

SRC="$PROJECT_DIR/docs/claude-memory"
if [ ! -d "$SRC" ]; then
  echo "Errore: $SRC non trovato." >&2
  exit 1
fi

mkdir -p "$DEST"
cp "$SRC"/*.md "$DEST"/

echo "Memoria Claude installata in:"
echo "  $DEST"
echo "File copiati:"
ls -1 "$DEST"
echo
echo "Apri il progetto con Claude Code da: $PROJECT_DIR"
