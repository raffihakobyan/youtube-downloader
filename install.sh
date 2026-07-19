#!/usr/bin/env bash
#
# install.sh — установка download-yt одной командой.
#
# Локально:
#   ./install.sh
#
# Или напрямую из GitHub:
#   curl -fsSL https://raw.githubusercontent.com/raffihakobyan/youtube-downloader/main/install.sh | bash
#
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/raffihakobyan/youtube-downloader/main"
SCRIPT_NAME="download-yt"

C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
info() { printf '%s➜%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s⚠%s  %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '%s✗%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }

# --- 1. Homebrew -------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  err "Homebrew не найден. Установите его: https://brew.sh"
  exit 1
fi

# --- 2. Зависимости: yt-dlp + ffmpeg ----------------------------------------
for dep in yt-dlp ffmpeg; do
  if command -v "$dep" >/dev/null 2>&1; then
    info "$dep уже установлен."
  else
    info "Устанавливаю $dep через Homebrew…"
    brew install "$dep"
  fi
done

# --- 3. Выбор каталога для бинарника (первый доступный на запись из PATH) -----
choose_bindir() {
  for d in "/opt/homebrew/bin" "/usr/local/bin" "$HOME/.local/bin"; do
    case ":$PATH:" in
      *":$d:"*) if [[ -w "$d" ]] || [[ ! -e "$d" && -w "$(dirname "$d")" ]]; then
                  echo "$d"; return 0
                fi ;;
    esac
  done
  # запасной вариант — ~/.local/bin (создадим и предупредим про PATH)
  echo "$HOME/.local/bin"
}

BIN_DIR="$(choose_bindir)"
mkdir -p "$BIN_DIR"
DEST="$BIN_DIR/$SCRIPT_NAME"

# --- 4. Установка самого скрипта --------------------------------------------
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SRC_DIR/$SCRIPT_NAME" ]]; then
  info "Копирую $SCRIPT_NAME → $DEST"
  cp "$SRC_DIR/$SCRIPT_NAME" "$DEST"
else
  info "Скачиваю $SCRIPT_NAME из GitHub → $DEST"
  curl -fsSL "$REPO_RAW/$SCRIPT_NAME" -o "$DEST"
fi
chmod +x "$DEST"

# --- 5. Проверка PATH --------------------------------------------------------
case ":$PATH:" in
  *":$BIN_DIR:"*) : ;;
  *) warn "Каталог $BIN_DIR не в PATH."
     warn "Добавьте в ~/.zshrc строку:"
     warn "  export PATH=\"$BIN_DIR:\$PATH\""
     warn "и выполните: source ~/.zshrc" ;;
esac

printf '\n%s✓ Готово!%s Установлено в: %s\n\n' "$C_GREEN$C_BOLD" "$C_RESET" "$DEST"
printf 'Примеры:\n'
printf '  download-yt https://www.youtube.com/watch?v=vZqvVhcHsZM 720\n'
printf '  download-yt https://www.youtube.com/watch?v=vZqvVhcHsZM 1080\n'
printf '  download-yt https://www.youtube.com/watch?v=vZqvVhcHsZM mp3\n'
