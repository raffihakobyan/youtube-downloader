# download-yt

Простой CLI для macOS, чтобы скачивать видео и аудио с YouTube одной короткой командой.

```bash
download-yt "<URL>"         # видео 1080p по умолчанию (mp4)
download-yt "<URL>" 720     # видео до 720p  (mp4)
download-yt "<URL>" mp3     # аудио в mp3, максимальное качество
```

> ⚠️ **Ссылку всегда берите в кавычки.** В zsh символы `?` и `&` из URL
> раскрываются как шаблон, и без кавычек вы получите ошибку
> `zsh: no matches found`.

Под капотом — [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) + [`ffmpeg`](https://ffmpeg.org/).

---

## Возможности

- 🎬 **Видео** любого разрешения (`144`, `240`, `360`, `480`, `720`, `1080`, `1440`, `2160`) — скачивается лучшая дорожка **не выше** указанной высоты и склеивается в `mp4`.
- 🎵 **Аудио mp3** максимального качества (`--audio-quality 0`).
- ⚙️ **Качество по умолчанию — 1080p**, если второй аргумент не указан.
- 📂 **Сохраняет в текущую папку терминала** (можно переопределить `DOWNLOAD_YT_DIR`).
- 🔁 **Автоконвертация**: если у видео нет готовой mp3-дорожки, аудио **конвертируется локально через ffmpeg** (на «железе» вашего Mac).
- 🏷 Встраивает метаданные и обложку.
- 🔁 **Автоповтор при ошибке HTTP 403** — до 3 попыток со свежими ссылками.
- 📦 Установка и удаление — **одной командой**.

---

## Требования

- macOS
- [Homebrew](https://brew.sh) (установщик сам поставит `yt-dlp` и `ffmpeg`)

---

## Установка

### Локально (из клона репозитория)

```bash
git clone https://github.com/raffihakobyan/youtube-downloader.git
cd youtube-downloader
./install.sh
```

### Одной командой (напрямую из GitHub)

```bash
curl -fsSL https://raw.githubusercontent.com/raffihakobyan/youtube-downloader/main/install.sh | bash
```

Установщик:
1. проверит Homebrew;
2. установит `yt-dlp` и `ffmpeg` (если их ещё нет);
3. положит команду `download-yt` в подходящий каталог из `PATH`.

---

## Использование

```bash
download-yt "https://www.youtube.com/watch?v=vZqvVhcHsZM"        # 1080p по умолчанию
download-yt "https://www.youtube.com/watch?v=vZqvVhcHsZM" 720
download-yt "https://www.youtube.com/watch?v=vZqvVhcHsZM" mp3
```

Файлы сохраняются в **текущую папку**, из которой запущена команда.
Изменить каталог можно переменной окружения:

```bash
DOWNLOAD_YT_DIR="$HOME/Music" download-yt "<URL>" mp3
```

Справка и версия:

```bash
download-yt --help
download-yt --version
```

---

## Удаление

### Локально

```bash
./uninstall.sh
```

### Одной командой

```bash
curl -fsSL https://raw.githubusercontent.com/raffihakobyan/youtube-downloader/main/uninstall.sh | bash
```

Удаляется только сама команда `download-yt`. Зависимости `yt-dlp` и `ffmpeg`
остаются (их могут использовать другие программы). Чтобы удалить и их:

```bash
brew uninstall yt-dlp ffmpeg
```

---

## Как это работает

| Аргумент | Формат yt-dlp | Результат |
|----------|---------------|-----------|
| _(не указан)_ | как `1080` | `mp4` до 1080p |
| число (напр. `720`) | `bv*[height<=720]+ba/b[height<=720]/…` | `mp4` до указанной высоты |
| `mp3` | `-x --audio-format mp3 --audio-quality 0` | `mp3`, лучшее качество |

Для `mp3` yt-dlp скачивает лучшую аудиодорожку и передаёт её `ffmpeg`,
который конвертирует её в mp3. Отдельной mp3-дорожки на YouTube нет —
поэтому конвертация всегда выполняется локально.

---

## Устранение неполадок

- **`zsh: no matches found: https://...`** — вы не взяли ссылку в кавычки.
  zsh раскрывает `?` и `&` как шаблон файла. Правильно:
  ```bash
  download-yt "https://www.youtube.com/watch?v=vZqvVhcHsZM" 720
  ```
- **`download-yt: command not found`** — каталог установки не в `PATH`.
  Установщик подскажет, какую строку добавить в `~/.zshrc`, например:
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```
- **`HTTP Error 403: Forbidden`** — «плавающая» ошибка YouTube: сервер
  отклоняет выданную ссылку на поток. `download-yt` сам повторяет загрузку
  до 3 раз со свежими ссылками, что обычно её устраняет. Если 403 не уходит —
  обновите yt-dlp (ниже).
- **Ошибки скачивания / устаревший формат** — обновите yt-dlp:
  ```bash
  brew upgrade yt-dlp
  ```

---

## Лицензия

[MIT](LICENSE)

> Скачивайте только тот контент, на который у вас есть права, и соблюдайте
> [Условия использования YouTube](https://www.youtube.com/t/terms).
