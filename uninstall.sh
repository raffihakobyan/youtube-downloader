#!/usr/bin/env bash
#
# uninstall.sh — удаление download-yt одной командой.
#
# Локально:
#   ./uninstall.sh
#
# Или напрямую из GitHub:
#   curl -fsSL https://raw.githubusercontent.com/raffihakobyan/youtube-downloader/main/uninstall.sh | bash
#
# Зависимости yt-dlp и ffmpeg НЕ удаляются (могут использоваться другими программами).
# Чтобы удалить и их:  brew uninstall yt-dlp ffmpeg
#
set -euo pipefail

SCRIPT_NAME="download-yt"

C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
info() { printf '%s➜%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s⚠%s  %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }

removed=0
# Удаляем все копии download-yt из типичных каталогов и из PATH.
for d in "/opt/homebrew/bin" "/usr/local/bin" "$HOME/.local/bin"; do
  target="$d/$SCRIPT_NAME"
  if [[ -e "$target" ]]; then
    info "Удаляю $target"
    rm -f "$target"
    removed=1
  fi
done

# На случай, если установлено в нестандартный каталог из PATH.
if command -v "$SCRIPT_NAME" >/dev/null 2>&1; then
  leftover="$(command -v "$SCRIPT_NAME")"
  info "Удаляю $leftover"
  rm -f "$leftover"
  removed=1
fi

if [[ "$removed" -eq 1 ]]; then
  printf '\n%s✓ download-yt удалён.%s\n' "$C_GREEN$C_BOLD" "$C_RESET"
else
  warn "download-yt не найден — возможно, уже удалён."
fi

printf '\nЗависимости оставлены. Чтобы удалить их вручную:\n'
printf '  brew uninstall yt-dlp ffmpeg\n'
