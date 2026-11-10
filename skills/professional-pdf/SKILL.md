---
name: professional-pdf
description: Genera PDF professionali per attività e liberi professionisti — preventivi, offerte commerciali, report, company profile, listini prezzi, menu, schede prodotto, proposte, certificati, CV aziendali. Impagina in HTML/CSS e stampa in PDF con Chrome headless o il Playwright MCP. Usa quando l'utente chiede "crea un PDF", "fammi un preventivo", "genera un report/listino/menu/company profile in PDF", "documento professionale da stampare".
---

# Professional PDF

Producono documenti PDF multipagina di qualità tipografica, partendo da un
singolo file HTML. Le regole di qualità del plugin (`rules/AGENTS.md`) sono
sempre attive: rispettale.

Percorsi utili (assoluti):

- Template base A4: `~/.gemini/config/plugins/pdf-studio/skills/professional-pdf/templates/document-a4.html`
- Script di rendering: `~/.gemini/config/plugins/pdf-studio/skills/professional-pdf/scripts/render.sh`
- Cartella output: `~/Documents/PDF-Studio/<slug>/`

## 1. Brief (rapido)

Raccogli solo ciò che manca, in un unico messaggio (non fare 10 domande):

- Tipo di documento e scopo (es. preventivo per cliente X, listino 2027).
- Nome attività, settore, città; logo (file) e colori/font del brand se esistono.
- Contenuti reali: voci e prezzi, testi, dati, contatti, P.IVA.
- Formato (default A4 verticale), lingua (default italiano), n. pagine indicativo.

Se l'utente dice "fai tu", procedi con contenuti plausibili e marca i dati
inventati come **da verificare** nel messaggio finale.

## 2. Scegli la struttura

| Documento | Struttura consigliata |
| --- | --- |
| Preventivo / offerta | Copertina leggera o header · dati cliente · descrizione progetto · tabella voci · totali + IVA · condizioni/tempi/validità · firme |
| Report | Copertina · sommario esecutivo · KPI (stat grandi) · sezioni con grafici SVG inline · conclusioni |
| Company profile | Copertina · chi siamo · servizi (card) · numeri · clienti/casi · team · contatti |
| Listino / menu | Header brand · categorie con righe nome ⋯ prezzo · note allergeni/condizioni · footer contatti |
| Scheda prodotto | Hero immagine · benefici · specifiche (tabella) · CTA |

Grafici: disegnali in **SVG inline** (barre, torte, linee) calcolando le
coordinate; niente librerie JS esterne.

## 3. Impagina

1. `mkdir -p ~/Documents/PDF-Studio/<slug>` e copia il template come
   `index.html` (oppure scrivi l'HTML da zero seguendo lo stesso schema).
2. Imposta le variabili CSS `--primary`, `--accent`, i font, e sostituisci
   **tutti** i segnaposto `{{...}}` (verifica con `grep -n '{{' index.html`:
   deve restituire zero righe).
3. Una `<section class="page">` per pagina. Se un contenuto non entra, crea
   una nuova pagina invece di ridurre il font sotto 9pt.
4. Logo/immagini dell'utente: copiale nella cartella del progetto e usa
   percorsi relativi (`<img src="logo.png">`).
5. Numeri di pagina nel `.running-foot`, aggiornati a mano.

## 4. Rendering

Metodo A — script (preferito):

```bash
bash ~/.gemini/config/plugins/pdf-studio/skills/professional-pdf/scripts/render.sh ~/Documents/PDF-Studio/<slug>/index.html ~/Documents/PDF-Studio/<slug>/<Nome-Documento>.pdf --preview
```

Lancia questo comando con `BypassSandbox: true` (Chrome non parte nel
sandbox). Lo script stampa numero di pagine e formato reale: confrontali con
quanto atteso.

Metodo B — Playwright MCP (`pdf-studio_playwright`):

1. `browser_navigate` → `file:///Users/<utente>/Documents/PDF-Studio/<slug>/index.html`
   (se l'accesso `file://` viene bloccato, servi la cartella con
   `python3 -m http.server 8765 --directory <cartella>` come processo in
   background e naviga su `http://localhost:8765/index.html`).
2. `browser_run_code` con:
   ```js
   async (page) => {
     await page.emulateMedia({ media: 'print' });
     await page.pdf({ path: '/Users/<utente>/Documents/PDF-Studio/<slug>/<Nome>.pdf',
       printBackground: true, preferCSSPageSize: true });
   }
   ```
   In assenza di `browser_run_code`, usa `browser_pdf_save` (formato del
   browser; verifica che le pagine non risultino Letter).

## 5. Controllo qualità (obbligatorio)

- Guarda l'anteprima (`<file>.pdf.png` generata da `--preview`, oppure
  `browser_take_screenshot` con `fullPage: true` della pagina HTML).
- Verifica: numero pagine atteso (lo script lo stampa), nessuna pagina bianca
  extra, nessun testo tagliato da `overflow: hidden`, allineamenti, contrasto,
  totali matematicamente corretti, nessun `{{` residuo.
- Correggi e ri-renderizza finché non è pulito.

## 6. Consegna

Rispondi con: link al PDF, link all'`index.html` sorgente, elenco breve dei
dati "da verificare", e proposta di varianti (palette, versione inglese,
versione Canva modificabile tramite il plugin Canva).
