# PDF Studio — regole sempre attive

Queste regole valgono ogni volta che generi un PDF, una brochure, un flyer, un
listino, un preventivo o qualsiasi documento stampabile con il plugin PDF Studio.

## Pipeline obbligatoria

1. **HTML/CSS come sorgente.** Ogni documento nasce come un singolo file
   `index.html` (CSS inline nel `<style>`, immagini locali o data URI) dentro
   `~/Documents/PDF-Studio/<slug-progetto>/`. Mai generare PDF "a mano" o con
   librerie che non supportano CSS moderno.
2. **Rendering in PDF** con uno di questi due metodi (in ordine di preferenza):
   - Script locale: `bash ~/.gemini/config/plugins/pdf-studio/skills/professional-pdf/scripts/render.sh <input.html> [output.pdf]`
     (Chrome headless, rispetta `@page size`, deterministico). **Eseguilo
     sempre con `BypassSandbox: true`**: dentro il sandbox del terminale Chrome
     va in crash ("Trace/BPT trap"). Esegui fuori dal sandbox solo questo
     comando; la preparazione dei file resta nel sandbox.
   - Playwright MCP (`pdf-studio_playwright`): `browser_navigate` su
     `file:///…/index.html` e poi `browser_run_code` con
     `await page.pdf({ path, format: 'A4', printBackground: true, preferCSSPageSize: true })`;
     se `browser_run_code` non è disponibile usa `browser_pdf_save`.
3. **Controllo visivo obbligatorio** prima di consegnare: genera le anteprime
   PNG (lo script lo fa con `--preview`) oppure usa `browser_take_screenshot`,
   guardale e correggi overflow, testo tagliato, pagine vuote, orfani, contrasto.
4. Consegna all'utente il percorso del PDF e dell'HTML sorgente (editabile).

## Standard di qualità

- Formato di default **A4** (210×297 mm) salvo richiesta diversa; usa sempre
  `@page { size: …; margin: 0 }` e gestisci i margini dentro `.page`.
- Ogni pagina è un `<section class="page">` di dimensioni fisse con
  `page-break-after: always` e `overflow: hidden`: niente contenuti che
  "scivolano" sulla pagina successiva in modo incontrollato.
- Includi sempre `-webkit-print-color-adjust: exact; print-color-adjust: exact;`
  così sfondi e colori vengono stampati.
- Tipografia: massimo 2 famiglie di font. Corpo 9.5–11pt, interlinea 1.4–1.6,
  gerarchia chiara (H1 ≥ 2.2× il corpo). Usa sempre uno stack di fallback di
  sistema (`"Helvetica Neue", Arial, sans-serif` / `Georgia, serif`) perché i web
  font potrebbero non caricarsi offline.
- Palette: 1 colore primario + 1 accento + neutri. Se l'utente ha un brand
  (logo, colori HEX, font) usalo; altrimenti proponi una palette coerente con
  il settore e dichiarala.
- Contrasto testo/sfondo ≥ 4.5:1. Margini di sicurezza ≥ 10 mm (≥ 3 mm di
  abbondanza/bleed se l'utente dice che va in tipografia).
- Testi in **italiano** corretto, salvo diversa richiesta. Niente lorem ipsum
  nel risultato finale: se mancano dati, scrivi copy plausibile e segnalalo
  chiaramente all'utente come "da verificare" (prezzi, indirizzi, P.IVA, orari).
- Importi in formato italiano (`1.250,00 €`), date `10 novembre 2026`.
- Immagini: usa quelle fornite dall'utente; altrimenti forme, gradienti, icone
  SVG inline, oppure genera immagini con il subagente `image-generator` se
  l'utente lo desidera. Mai hotlink a immagini protette da copyright.

## Integrazione con Canva

Se l'utente vuole un design **modificabile in Canva** invece di (o oltre a) un
PDF, usa le skill del plugin Canva già installato (generate-design /
export-design in formato PDF). PDF Studio resta il default per documenti
testuali densi (preventivi, report, listini) dove serve controllo preciso.
