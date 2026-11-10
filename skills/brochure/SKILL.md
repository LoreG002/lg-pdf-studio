---
name: brochure
description: Crea brochure, depliant, flyer, volantini e cataloghi per attività commerciali (ristoranti, hotel, studi professionali, negozi, palestre, agenzie, eventi) in PDF pronto per la stampa o per il digitale — formati a tre ante (trifold), a due ante (bifold), flyer A5/A4, catalogo multipagina. Usa quando l'utente chiede "crea una brochure", "depliant", "volantino", "flyer", "pieghevole", "catalogo" per un'attività.
---

# Brochure & Flyer

Si appoggia alla pipeline della skill `professional-pdf` (stesso script di
rendering e stesso controllo qualità) ma con layout pensati per la piegatura e
per il marketing. Le regole di `rules/AGENTS.md` restano attive.

Percorsi utili:

- Template trifold A4: `~/.gemini/config/plugins/pdf-studio/skills/brochure/templates/trifold-a4.html`
- Script: `~/.gemini/config/plugins/pdf-studio/skills/professional-pdf/scripts/render.sh`

## 1. Brief marketing

Chiedi (in un solo messaggio, solo ciò che manca):

- Attività, settore, città, pubblico target, tono (elegante, giovane, tecnico, familiare).
- Obiettivo della brochure (far prenotare, presentare servizi, promo stagionale, evento).
- Call-to-action principale (telefona, prenota online, visita, scansiona QR).
- Contenuti: servizi/prodotti, prezzi o pacchetti, punti di forza, contatti, orari, social.
- Brand: logo, colori, font, foto. Formato e uso (stampa in tipografia o digitale).

## 2. Scegli il formato

| Formato | `@page` | Struttura |
| --- | --- | --- |
| Trifold A4 (3 ante) | `A4 landscape` | 2 facciate × 3 pannelli (vedi template) |
| Bifold A4 → A5 (2 ante) | `A4 landscape` | 2 facciate × 2 pannelli da 148,5 mm: esterno [retro · copertina], interno [sx · dx] |
| Flyer A5 | `148mm 210mm` | 1–2 pagine: hero, 3 benefici, offerta, CTA, contatti |
| Flyer A4 | `A4` | come A5, con più spazio per immagini |
| Catalogo | `A4` o `210mm 210mm` | copertina · indice · pagine prodotto in griglia · retro contatti |
| Brochure digitale | `A4` | pagine singole lette a schermo, link cliccabili `<a href>` |

Per la **stampa in tipografia** aggiungi 3 mm di abbondanza: dimensione pagina
+6 mm per lato totale (es. A4 → `216mm 303mm`), sfondi che arrivano al bordo,
testi ad almeno 8 mm dal taglio. Avvisa l'utente che il PDF è RGB: per CMYK
deve chiedere conversione alla tipografia.

## 3. Principi di design brochure

- **Copertina**: una promessa forte (max 8 parole), nome attività ben visibile,
  un'immagine o forma grafica dominante. Niente muri di testo.
- **Una idea per pannello**, titoli brevi, paragrafi ≤ 60 parole, elenchi puntati.
- **Gerarchia**: eyebrow (maiuscoletto colorato) → titolo serif/sans grande → corpo.
- **CTA ripetuta** almeno due volte (pannello offerta + retro), con QR code
  se c'è un URL: generalo come SVG inline (es. con `npx -y qrcode -t svg "<url>"`
  oppure Python `segno`/`qrcode` se disponibili), altrimenti lascia il box
  segnaposto e dillo all'utente.
- Palette per settore (se manca il brand): ristorazione → verdi/terracotta/crema;
  benessere → salvia/sabbia; tech → blu notte/elettrico; lusso → nero/oro;
  bambini → colori pastello saturi; professioni legali/finanza → blu/grigio.
- Immagini: preferisci foto fornite dall'utente; altrimenti gradienti, pattern
  SVG, illustrazioni generate con il subagente `image-generator` (chiedi
  conferma) salvate nella cartella del progetto.
- Testo: copy persuasivo ma concreto (benefici, numeri, prove sociali). Niente
  superlativi vuoti.

## 4. Produzione

1. `mkdir -p ~/Documents/PDF-Studio/<slug>`; copia il template più vicino come
   `index.html` o scrivi il layout da zero seguendo lo schema `.sheet` / `.panel`.
2. Compila tutti i segnaposto (`grep -n '{{' index.html` → zero risultati).
3. Renderizza:
   ```bash
   bash ~/.gemini/config/plugins/pdf-studio/skills/professional-pdf/scripts/render.sh ~/Documents/PDF-Studio/<slug>/index.html ~/Documents/PDF-Studio/<slug>/Brochure-<Attivita>.pdf --preview
   ```
   In alternativa usa il Playwright MCP come descritto nella skill `professional-pdf`.
4. **QA visivo**: controlla l'anteprima / screenshot di entrambe le facciate
   (per vedere la seconda facciata usa `browser_take_screenshot` full page
   dell'HTML via Playwright MCP). Verifica ordine dei pannelli per la piega,
   pagine attese (trifold/bifold = 2), testo che non esce dai pannelli.
5. Facoltativo: versione social (post 1080×1080 / story 1080×1920) dallo
   stesso HTML con `@page { size: 1080px 1080px }`, oppure via plugin Canva
   (resize-for-social-media) se l'utente vuole il design in Canva.

## 5. Consegna

PDF + HTML sorgente, istruzioni di piega (per trifold: "piegare prima il
pannello sinistro dell'esterno verso l'interno, poi chiudere con la copertina"),
dati da verificare, suggerimento di 1–2 varianti (palette / promo stagionale).
