#!/usr/bin/env bash
# PDF Studio — render an HTML file to PDF with headless Chrome.
# Usage: render.sh <input.html> [output.pdf] [--preview]
#   --preview  also writes a PNG thumbnail of page 1 next to the PDF (macOS qlmanage)
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: render.sh <input.html> [output.pdf] [--preview]" >&2
  exit 1
fi

IN="$1"; shift
OUT=""
PREVIEW=0
for a in "$@"; do
  case "$a" in
    --preview) PREVIEW=1 ;;
    *) OUT="$a" ;;
  esac
done

[[ -f "$IN" ]] || { echo "File non trovato: $IN" >&2; exit 1; }
ABS_IN="$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")"
[[ -n "$OUT" ]] || OUT="${ABS_IN%.*}.pdf"
mkdir -p "$(dirname "$OUT")"
ABS_OUT="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"

CHROME=""
for c in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium" \
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
  "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  "$(command -v google-chrome 2>/dev/null || true)" \
  "$(command -v chromium 2>/dev/null || true)"; do
  if [[ -n "$c" && -x "$c" ]]; then CHROME="$c"; break; fi
done
[[ -n "$CHROME" ]] || { echo "Chrome/Chromium non trovato. Usa il Playwright MCP (pdf-studio_playwright)." >&2; exit 2; }

PROFILE="$(mktemp -d /tmp/pdfstudio-chrome.XXXXXX)"
trap 'rm -rf "$PROFILE"' EXIT

"$CHROME" \
  --headless=new \
  --disable-gpu \
  --no-first-run \
  --no-default-browser-check \
  --user-data-dir="$PROFILE" \
  --allow-file-access-from-files \
  --no-pdf-header-footer \
  --virtual-time-budget=8000 \
  --run-all-compositor-stages-before-draw \
  --print-to-pdf="$ABS_OUT" \
  "file://$ABS_IN" >/dev/null 2>&1

[[ -s "$ABS_OUT" ]] || { echo "Rendering fallito: PDF vuoto o assente." >&2; exit 3; }

INFO="$(osascript -l JavaScript -e "ObjC.import('PDFKit'); var d=\$.PDFDocument.alloc.initWithURL(\$.NSURL.fileURLWithPath('$ABS_OUT')); var b=d.pageAtIndex(0).boundsForBox(0); d.pageCount + ' (pagina ' + Math.round(b.size.width/72*25.4) + 'x' + Math.round(b.size.height/72*25.4) + ' mm)'" 2>/dev/null || echo '?')"
echo "PDF: $ABS_OUT"
echo "Pagine: $INFO"
echo "Dimensione: $(du -h "$ABS_OUT" | cut -f1)"

if [[ "$PREVIEW" == 1 ]] && command -v qlmanage >/dev/null; then
  qlmanage -t -s 1400 -o "$(dirname "$ABS_OUT")" "$ABS_OUT" >/dev/null 2>&1 || true
  [[ -f "$ABS_OUT.png" ]] && echo "Anteprima pag.1: $ABS_OUT.png"
fi
